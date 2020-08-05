;; Copyright 2020 Bastien Léonard. All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:

;;    1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.

;;    2. Redistributions in binary form must reproduce the above
;;    copyright notice, this list of conditions and the following
;;    disclaimer in the documentation and/or other materials provided
;;    with the distribution.

;; THIS SOFTWARE IS PROVIDED BY BASTIEN LÉONARD ``AS IS'' AND ANY
;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BASTIEN LÉONARD OR
;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
;; USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
;; OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.

(local colors (require :colors))
(local Config (require :config))
(local DeathScreen (require :death-screen))
(local DefaultEventHandler (require :default-event-handler))
(local EventHandlers (require :event-handlers))
(local FramesGraphView (require :frames-graph-view))
(local fonts (require :fonts))
(local FovState (require :fov-state))
(local GameScreen (require :game-screen))
(local generate-dungeon (require :dungeon-generator))
(local InventoryView (require :inventory-view))
(local Item (require :item))
(local ItemKind (require :item-kind))
(local PlayerAction (require :player-action))
(local random (require :random))
(local shortest-path (require :shortest-path))
(local TileContentView (require :tile-content-view))
(local TileKind (require :tile-kind))
(local make-tileset (require :tileset))
(local Screens (require :screens))
(local Unit (require :unit))
(local utils (require :utils))
(local {:not-nil? not-nil?} (require :utils))

(local MAX-MAP-WIDTH 100)
(local MAX-MAP-HEIGHT 100)

(lambda on-hero-death []
  (screens:replace-current (DeathScreen.new))
  nil)

(lambda update-sprite-batch [sprite-batch map tileset]
  (sprite-batch:clear)

  (each [[x y tile] (map:iter)]
    (local tile-kind tile.kind)
    (var row nil)
    (var column nil)
    (local unit tile.unit)

    ;; TODO: delegate to Tileset
    (local (row column) (if (and config.fov-enabled?
                                 (= tile.fov-state FovState.UNEXPLORED))
                            (values nil nil)
                            (Unit.hero? unit)
                            (values 0 27)
                            (not= unit nil)
                            (values 0 28)
                            (match tile-kind
                              TileKind.VOID (values 0 16)
                              TileKind.WALL (values 13 0)
                              TileKind.HALL (values 0 2)
                              TileKind.SHELF (values 7 3)
                              TileKind.SHELF-WITH-SKULL (values 7 4)
                              TileKind.SKULL (values 15 0)
                              TileKind.CHEST (values 6 8)
                              TileKind.STAIRS-DOWN (values 6 3)
                              _ (error (: "Unhandled tile kind %s"
                                          :format
                                          tile-kind)))))
    (when (and (not-nil? row) (not-nil? column))
      (var color
           (if (= tile.unit nil)
               (tileset:color-of-tile-kind tile-kind)
               (tileset:color-of-unit tile.unit)))
      (when (and config.fov-enabled?
                 (= tile.fov-state FovState.EXPLORED-OUT-OF-SIGHT))
        ;; TODO: optimize (don't create a new table)
        (set color (utils.dup-table color))
        (tset color 4 0.5))
      (sprite-batch:setColor (unpack color))
      (sprite-batch:add (love.graphics.newQuad
                         (* column tileset.tile-width)
                         (* row tileset.tile-height)
                         tileset.tile-width
                         tileset.tile-height
                         tileset.width
                         tileset.height)
                        (* x tileset.tile-width)
                        (* y tileset.tile-height))))

  (sprite-batch:flush)
  nil)

(lambda reset-sprite-batch [map tileset]
  (update-sprite-batch sprite-batch map tileset))

(lambda remove-unit [unit map]
  (assert (not (Unit.hero? unit)))
  (global enemies
          (utils.filter enemies
                        (lambda [enemy] (not= enemy unit))))
  (map:set-unit! unit.x unit.y nil)
  nil)

;; Basic improvised algorithm. Will probably need to be improved for
;; the FOV to work as expected.
(lambda is-visible-to? [x y unit map]
  (let [x (if (< x unit.x)
              (+ x 1)
              (> x unit.x)
              (- x 1)
              x)
        y (if (< y unit.y)
              (+ y 1)
              (> y unit.y)
              (- y 1)
              y)]
    (if (and (= x unit.x) (= y unit.y))
        true
        (and (not (: (map:get! x y) :blocks-sight?))
             (is-visible-to? x y unit map)))))

(lambda fov-tiles [unit]
  (let [coords []
        range unit.fov-range]
    (for [x (- unit.x range) (+ unit.x range)]
      (for [y (- unit.y range) (+ unit.y range)]
        (let [tile (map:get-or-nil x y)]
          (when (and (not= tile nil) (is-visible-to? x y unit map))
            (table.insert coords [x y])))))
    coords))

(lambda update-hero-fov [hero map]
  (when (not config.fov-enabled?)
    (lua :return))

  (each [[x y tile] (map:iter)]
    (when (= tile.fov-state FovState.EXPLORED-IN-SIGHT)
      (set tile.fov-state FovState.EXPLORED-OUT-OF-SIGHT))
    nil)

  (each [i [x y] (ipairs (fov-tiles hero))]
    (let [tile (map:get! x y)]
      (set tile.fov-state FovState.EXPLORED-IN-SIGHT)))
  nil)

(lambda center-camera-on-hero [tileset]
  (global camera-x (- (/ (love.graphics.getWidth) 2)
                      (* hero.x tileset.tile-width camera-scale)))
  (global camera-y (- (/ (love.graphics.getHeight) 2)
                      (* hero.y tileset.tile-height camera-scale)))
  nil)

(lambda move-to-next-level []
  (local width (love.math.random 10 MAX-MAP-WIDTH))
  (local height (love.math.random 10 MAX-MAP-HEIGHT))
  (print (: "Generating %sx%s dungeon..."
            :format
            width
            height))
  (let [(bound-map rooms) (generate-dungeon width height)
        hero-room (random.random-entry rooms)
        enemies-count (math.max 1
                                (math.floor (* bound-map.width
                                               bound-map.height
                                               0.005)))]
    (global map bound-map)

    (let [[x y] (hero-room:random-tile)]
      (if (= hero nil)
          (global hero
                  (Unit.new x y 10 10 5))
          (do
            (set hero.x x)
            (set hero.y y))))
    (map:set-unit! hero.x hero.y hero)
    (global enemies [])
    (print (: "Generating %d enemies..."
              :format
              enemies-count))

    ;; TODO: move to dungeon-generator
    (for [i 1 enemies-count]
      (let [random-empty-tile (lambda random-empty-tile [map rooms]
                                (let [room (random.random-entry rooms)
                                      [x y] (room:random-tile)
                                      tile (map:get! x y)]
                                  (if (tile:walkable?)
                                      [x y]
                                      (random-empty-tile map rooms))))
            [x y] (random-empty-tile map rooms)
            enemy (Unit.new x y 3 3 3)]
        (table.insert enemies enemy)
        (map:set-unit! enemy.x enemy.y enemy)))
    (print "Done generating enemies")

    (print "Done generating dungeon")
    (update-hero-fov hero map)
    (reset-sprite-batch map tileset)
    (center-camera-on-hero tileset))
  nil)

(lambda open-chest [tile]
  (assert (= tile.kind TileKind.CHEST))
  (set tile.kind TileKind.VOID)
  (let [item (Item.new (random.random-entry ItemKind.ALL)
                       1)]
    (hero:give-item item))
  nil)

(lambda on-hero-moved [hero map tileset]
  (center-camera-on-hero tileset)
  (let [tile (map:get! hero.x hero.y)]
    (match tile.kind
      TileKind.STAIRS-DOWN (move-to-next-level)
      TileKind.CHEST (open-chest tile)))
  nil)

(lambda attack [attacker victim map]
  (when (= (victim:damage 1) :death)
    (if (Unit.hero? victim)
        (on-hero-death)
        (remove-unit victim map)))
  nil)

(lambda move-unit-to [unit map x y]
  (let [tile (map:get! x y)
        walkable? (tile:walkable?)]
    (when walkable?
      (map:set-unit! unit.x unit.y nil)
      (set unit.x x)
      (set unit.y y)
      (map:set-unit! unit.x unit.y unit))
    walkable?))

(lambda move-unit-by [unit map dx dy]
  (let [x (+ unit.x dx)
        y (+ unit.y dy)
        tile (map:get! x y)]
    (move-unit-to unit map x y)))

(lambda new-turn [action]
  (lambda handle-move [hero dx dy map]
    (let [x (+ hero.x dx)
          y (+ hero.y dy)
          tile (map:get! x y)]
      (if (tile:walkable?)
          (let [action-taken? (move-unit-to hero map x y)]
            (when action-taken?
              (on-hero-moved hero map tileset))
            action-taken?)
          (if (= tile.unit nil)
              false
              (do
                (attack hero tile.unit map)
                true)))))

  (lambda handle-item-use [input]
    (lambda handle-potion-use [potion]
      (hero:heal 5)
      (potion:dec-uses)
      (when (potion:zero-uses?)
        (hero:remove-item potion))
      true)
    (lambda handle-wand-use [wand target]
      (let [[x y] target
            ;; TODO: don't use global map
            tile (map:get! x y)
            unit tile.unit]
        (when (or (= unit nil) (Unit.hero? unit))
          (lua "return false"))
        (let [damage (match wand.kind
                       ItemKind.FIRE-WAND 2
                       ItemKind.DEATH-WAND unit.hp
                       _ (error (: "Unhandled wand kind %s"
                                   :format
                                   wand.kind)))]
          (match (unit:damage damage)
            :death (remove-unit unit map)))
        (reset-sprite-batch map tileset)
        (wand:dec-uses)
        (when (wand:zero-uses?)
          (hero:remove-item wand))
        true))
    (let [item input.item]
      (match item.kind
        ItemKind.POTION (handle-potion-use input.item)
        (wand-kind ? (ItemKind.wand? wand-kind)) (handle-wand-use
                                                              input.item
                                                              input.target)
        _ (error (: "Unhandled item kind %s use"
                    :format
                    item)))))

  (var prevent-enemies-move? false)
  (local action-taken?
         (if (action:move?)
             (match (. {PlayerAction.MOVE-LEFT [-1 0]
                        PlayerAction.MOVE-RIGHT [1 0]
                        PlayerAction.MOVE-UP [0 -1]
                        PlayerAction.MOVE-DOWN [0 1]}
                       action)
               [dx dy] (let [action-taken? (handle-move hero dx dy map)
                             hero-tile (map:get! hero.x hero.y)]
                         (when (= hero-tile.kind TileKind.STAIRS)
                           (set prevent-enemies-move? true))
                         action-taken?)
               _ (error (: "Unhandled move action %s"
                           :format
                           action)))
             (action:item-use?)
             (handle-item-use action)
             (error (: "Unhandle action %s"
                       :format
                       action))))

  (when (= action-taken? nil)
    (error "action-taken? should never be nil"))

  (when action-taken?
    (when (not prevent-enemies-move?)
      (each [i enemy (ipairs enemies)]
        (each [i [x y] (ipairs (fov-tiles enemy))]
          (when (and (= x hero.x) (= y hero.y))
            (let [path (shortest-path [enemy.x enemy.y]
                                      [hero.x hero.y]
                                      map)
                  path-first (. path 1)
                  [x y] path-first
                  tile (map:get! x y)]
              (if (tile:walkable?)
                  (move-unit-to enemy
                                map
                                x
                                y)
                  (Unit.hero? tile.unit)
                  (attack enemy hero map)))
            (lua :break)))))
    (update-hero-fov hero map)
    (reset-sprite-batch map tileset))
  nil)

(lambda love.load []
  (love.graphics.setBackgroundColor (unpack colors.BACKGROUND-COLOR))
  (love.graphics.setDefaultFilter :nearest :nearest 0)

  (global config (Config.new {:hero-invincible? false
                              :show-fps? false
                              :show-frame-durations? false
                              :show-tile-contents? false
                              :fatal-warnings? false
                              :fov-enabled? true}))
  (global screens (Screens.new (GameScreen.new)))
  (global event-handlers (EventHandlers:new))
  (event-handlers:push (DefaultEventHandler:new new-turn))

  (global font (fonts.get 100))

  (global tileset (make-tileset))
  (global sprite-batch (love.graphics.newSpriteBatch tileset.image))
  (global tile-content-view (TileContentView:new tileset))
  (global inventory-view (InventoryView.new))

  (global camera-x 0)
  (global camera-y 0)
  (global camera-scale 4)
  (global dragging false)
  (move-to-next-level)
  nil)

(lambda love.keypressed [key scancode is-repeat]
  (: (screens:current) :key-pressed key scancode is-repeat)
  nil)

(lambda love.mousepressed [x y button is-touch presses]
  (: (screens:current) :mouse-pressed x y button is-touch presses)
  nil)

(lambda love.mousereleased [x y button is-touch presses]
  (global dragging false)
  nil)

(lambda love.mousemoved [x y dx dy is-touch]
  (when dragging
    (global camera-x (+ camera-x dx))
    (global camera-y (+ camera-y dy)))
  nil)

(lambda love.wheelmoved [x y]
  (when (not= y 0)
    (global camera-scale
            (* camera-scale
               (* y (if (> y 0) 2 -0.5)))))
  nil)

(lambda love.update [dt]
  (when (and config.show-frame-durations? (= frames-graph-view nil))
    (global frames-graph-view (FramesGraphView:new)))

  (when (not= frames-graph-view nil)
    (frames-graph-view:update dt))
  nil)

(lambda love.draw []
  (: (screens:current) :draw)
  (when config.show-fps?
    (love.graphics.print (.. (love.timer.getFPS) " FPS") font))

  (when (not= frames-graph-view nil)
    (frames-graph-view:draw))
  nil)
