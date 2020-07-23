(local colors (require :colors))
(local DefaultEventHandler (require :default-event-handler))
(local EventHandlers (require :event-handlers))
(local FramesGraphView (require :frames-graph-view))
(local FovState (require :fov-state))
(local generate-dungeon (require :dungeon-generator))
(local Inventory (require :inventory))
(local PlayerInput (require :player-input))
(local random (require :random))
(local shortest-path (require :shortest-path))
(local TileContentView (require :tile-content-view))
(local TileKind (require :tile-kind))
(local make-tileset (require :tileset))
(local Unit (require :unit))
(local utils (require :utils))
(local {:not-nil? not-nil?} (require :utils))
(local Wand (require :wand))

(local MAX-MAP-WIDTH 100)
(local MAX-MAP-HEIGHT 100)

(lambda update-sprite-batch [sprite-batch map tileset]
  (sprite-batch:clear)

  (each [[x y tile] (map:iter)]
    (local tile-kind tile.kind)
    (var row nil)
    (var column nil)
    (local unit tile.unit)

    ;; TODO: delegate to Tileset
    (local (row column) (if (= tile.fov-state FovState.UNEXPLORED)
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
                              TileKind.STAIRS-DOWN (values 6 3)
                              _ (error (: "Unhandled tile kind %s"
                                          :format
                                          tile-kind)))))
    (when (and (not-nil? row) (not-nil? column))
      (var color
           (if (= tile.unit nil)
               (tileset:color-of-tile-kind tile-kind)
               (tileset:color-of-unit tile.unit)))
      (when (= tile.fov-state FovState.EXPLORED-OUT-OF-SIGHT)
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
  (each [[x y tile] (map:iter)]
    (when (= tile.fov-state FovState.EXPLORED-IN-SIGHT)
      (set tile.fov-state FovState.EXPLORED-OUT-OF-SIGHT))
    nil)

  (each [i [x y] (ipairs (fov-tiles hero))]
    (let [tile (map:get! x y)]
      (set tile.fov-state FovState.EXPLORED-IN-SIGHT)))
  nil)

(lambda random-tile-constrained [map predicate]
  (let [x (love.math.random 0 (- map.width 1))
        y (love.math.random 0 (- map.height 1))
        tile (map:get! x y)]
    (if (predicate x y tile)
        tile
        (random-tile-constrained map predicate))))

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
    (global hero
            (let [[x y] (hero-room:random-tile)]
              {:x x :y y :fov-range 5 :inventory (Inventory:new)}))
    (hero.inventory:add (Wand:new))
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
            enemy {:x x :y y :hp 3 :fov-range 3}]
        (table.insert enemies enemy)
        (map:set-unit! enemy.x enemy.y enemy)))
    (print "Done generating enemies")

    ;; TODO: move to dungeon-generator
    (let [decorations-count (math.max 1
                                      (math.floor (* bound-map.width
                                                     bound-map.height
                                                     0.01)))]
      (print (: "Placing %s decorations..." :format decorations-count))
      (for [i 1 decorations-count]
        (let [tile (random-tile-constrained
                    map
                    (lambda [x y tile]
                      (and (and (= tile.unit nil)
                                (= tile.kind TileKind.VOID))
                           (utils.all? (map:all-neighbors x y)
                                       (lambda [[x y tile]]
                                         (= tile.kind TileKind.VOID))))))]
          (assert (= tile.kind TileKind.VOID))
          (set tile.kind (random.random-entry [TileKind.SHELF
                                               TileKind.SHELF-WITH-SKULL
                                               TileKind.SKULL]))))
      (print "Done placing decorations"))

    ;; TODO: move to dungeon-generator
    (let [stairs-count (math.max 1
                                 (math.floor (* bound-map.width
                                                bound-map.height
                                                0.0006)))]
      (print (: "Placing %s stairs..." :format stairs-count))
      (for [i 1 stairs-count]
        (let [tile (random-tile-constrained
                    map
                    (lambda [x y tile]
                      (and (and (= tile.unit nil)
                                (= tile.kind TileKind.VOID))
                           (utils.all? (map:all-neighbors x y)
                                       (lambda [[x y tile]]
                                         (= tile.kind TileKind.VOID))))))]
          (assert (= tile.kind TileKind.VOID))
          (set tile.kind TileKind.STAIRS-DOWN)))
      (print "Done placing stairs"))
    (print "Done generating dungeon")

    (update-hero-fov hero map)
    (reset-sprite-batch map tileset)
    (center-camera-on-hero tileset))
  nil)

(lambda on-hero-moved [hero map tileset]
  (center-camera-on-hero tileset)
  (let [tile (map:get! hero.x hero.y)]
    (when (= tile.kind TileKind.STAIRS-DOWN)
      (move-to-next-level)))
  nil)

(lambda attack [attacker victim map]
  (set victim.hp (- victim.hp 1))
  (when (= victim.hp 0)
    (assert (not (Unit.hero? victim)))
    (remove-unit victim map))
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

;; TODO: the parameter should be a player action
(lambda new-turn [input]
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
    (let [[x y] input.target
          ;; TODO: don't use global map
          tile (map:get! x y)
          unit tile.unit]
      (when (and (not= unit nil) (not (Unit.hero? unit)))
        ;; TODO: decrease HP instead of killing
        (remove-unit unit map)
        ;; TODO: don't use globals
        (reset-sprite-batch map tileset)))
    true)

  (local action-taken
         (match input.kind
           :move (match (. {PlayerInput.LEFT [-1 0]
                            PlayerInput.RIGHT [1 0]
                            PlayerInput.UP [0 -1]
                            PlayerInput.DOWN [0 1]}
                           input)
                   [dx dy] (handle-move hero dx dy map)
                   _ (error (: "Unhandled input %s" :format input)))
           :item-use (handle-item-use input)
           _ (error (: "Unhandle input kind %s"
                       :format
                       input.kind))))

  (when (= action-taken nil)
    (error "action-taken should never be nil"))

  (when action-taken
    (each [i enemy (ipairs enemies)]
      (each [i [x y] (ipairs (fov-tiles enemy))]
        (when (and (= x hero.x) (= y hero.y))
          (let [path (shortest-path [enemy.x enemy.y]
                                    [hero.x hero.y]
                                    map)
                path-first (. path 1)
                [x y] path-first]
            ;; (print (: "Moving enemy to (%s,%s)"
            ;;           :format
            ;;           x
            ;;           y))
            (move-unit-to enemy
                          map
                          x
                          y))
          (lua :break))))
    (update-hero-fov hero map)
    ;; TODO: only recreate the batch when something changed
    (reset-sprite-batch map tileset))
  nil)

(lambda love.load []
  (love.graphics.setBackgroundColor (unpack colors.BACKGROUND-COLOR))
  (love.graphics.setDefaultFilter :nearest :nearest 0)

  (global event-handlers (EventHandlers:new))
  (event-handlers:push (DefaultEventHandler:new new-turn))
  (global font (love.graphics.newFont "assets/fonts/roboto/Roboto-Regular.ttf"
                                      100))


  (global tileset (make-tileset))
  (global sprite-batch (love.graphics.newSpriteBatch tileset.image
                                                     ;; (* MAX-MAP-WIDTH
                                                     ;;    MAX-MAP-HEIGHT)
                                                     ;; :stream
                                                     ))
  (global frames-graph-view (FramesGraphView:new))
  (global tile-content-view (TileContentView:new font tileset))

  (global camera-x 0)
  (global camera-y 0)
  (global camera-scale 4)
  (global dragging false)
  (move-to-next-level)
  nil)

(lambda love.keypressed [key scancode is-repeat]
  (: (event-handlers:current) :key-pressed key scancode is-repeat)
  nil)

(lambda love.mousepressed [x y button is-touch presses]
  (global dragging true)
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
  (frames-graph-view:update dt)

  ;;     -- for i = 1, love.math.random(10000) do
  ;;     --     print(i)
  ;;     -- end

  nil)

(lambda love.draw []
  (love.graphics.push)
  (love.graphics.translate camera-x camera-y)
  (love.graphics.scale camera-scale camera-scale)
  (love.graphics.draw sprite-batch)
  (: (event-handlers:current) :draw tileset)
  (love.graphics.pop)
  (love.graphics.print (.. (love.timer.getFPS) " FPS") font)
  (frames-graph-view:draw)
  (tile-content-view:draw map)
  nil)
