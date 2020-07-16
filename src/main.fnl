(local colors (require :colors))
(local FramesGraphView (require :frames-graph-view))
(local FovState (require :fov-state))
(local generate-dungeon (require :dungeon-generator))
(local PlayerInput (require :player-input))
(local random (require :random))
(local shortest-path (require :shortest-path))
(local TileContentView (require :tile-content-view))
(local TileKind (require :tile-kind))
(local make-tileset (require :tileset))
(local Unit (require :unit))
(local utils (require :utils))

(lambda update-hero-fov [hero map]
  (lambda fov-tiles [unit-x unit-y]
    (let [coords []
          range 5]
      (for [x (- unit-x range) (+ unit-x range)]
        (for [y (- unit-y range) (+ unit-y range)]
          (when (map:valid? x y)
            (table.insert coords [x y]))))
      coords))

  (map:iter (lambda [x y tile]
              (when (= tile.fov-state FovState.EXPLORED-IN-SIGHT)
                (set tile.fov-state FovState.EXPLORED-OUT-OF-SIGHT))
              nil))

  (each [i [x y] (ipairs (fov-tiles hero.x hero.y))]
    (let [tile (map:get! x y)]
      (set tile.fov-state FovState.EXPLORED-IN-SIGHT)))
  nil)

(lambda remove-unit [unit map]
  (assert (not (Unit.hero? unit)))
  (global enemies
          (utils.filter enemies
                        (lambda [enemy] (not= enemy unit))))
  (map:set-unit! unit.x unit.y nil)
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

(lambda make-sprite-batch [map tileset]
  ;; TODO: use let
  (local sprite-batch
         (love.graphics.newSpriteBatch tileset.image
                                       tileset.tile-count
                                       :static))
  ;; TODO: remove side effects
  (map:iter (lambda [x y tile]
              (local tile-kind tile.kind)
              (var row nil)
              (var column nil)
              (local unit tile.unit)

              (if (Unit.hero? unit)
                  (do
                    (set row 0)
                    (set column 27))
                  (not= unit nil)
                  (do
                    (set row 0)
                    (set column 28))
                  (= tile-kind TileKind.VOID)
                  (do
                    (set row 0)
                    (set column 16))
                  (= tile-kind TileKind.WALL)
                  (do
                    (set row 13)
                    (set column 0))
                  (= tilekind TileKind.HALL)
                  (do
                    (set row 0)
                    (set column 2)))

              ;; TODO: avoid unneeded previous checks
              (when (= tile.fov-state FovState.UNEXPLORED)
                (set row 0)
                (set column 0))

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
  sprite-batch)

;; TODO: the parameter should be a player action
(lambda new-turn [input]
  (var action-taken false)
  (match (. {PlayerInput.LEFT [-1 0]
             PlayerInput.RIGHT [1 0]
             PlayerInput.UP [0 -1]
             PlayerInput.DOWN [0 1]}
            input)
    [dx dy] (do
              (let [x (+ hero.x dx)
                    y (+ hero.y dy)
                    tile (map:get! x y)]
                (if (tile:walkable?)
                    (set action-taken (move-unit-to hero map x y))
                    (when (not= tile.unit nil)
                      (attack hero tile.unit map)
                      (set action-taken true))))))
  (when action-taken
    (each [i enemy (ipairs enemies)]
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
                      y)))
    (update-hero-fov hero map)
    ;; TODO: only recreate the batch when something changed
    (global sprite-batch (make-sprite-batch map tileset)))
  nil)

(lambda love.load []
  (love.graphics.setBackgroundColor (unpack colors.BACKGROUND-COLOR))
  (love.graphics.setDefaultFilter :nearest :nearest 0)

  (global font (love.graphics.newFont "assets/fonts/roboto/Roboto-Regular.ttf"
                                      100))

  (print "Generating dungeon...")
  (let [(bound-map rooms) (generate-dungeon 40 40)
        hero-room (random.random-entry rooms)
        enemies-count (math.max 1
                                (math.floor (* bound-map.width
                                               bound-map.height
                                               0.005)))]
    (print "Done generating dungeon")
    (global map bound-map)
    (global hero
            (let [[x y] (hero-room:random-tile)]
              {:x x :y y}))
    (map:set-unit! hero.x hero.y hero)
    (global enemies [])
    (print (: "Generating %d enemies..."
              :format
              enemies-count))
    (for [i 1 enemies-count]
      (let [random-empty-tile (lambda random-empty-tile [map rooms]
                                (let [room (random.random-entry rooms)
                                      [x y] (room:random-tile)
                                      tile (map:get! x y)]
                                  (if (tile:walkable?)
                                      [x y]
                                      (random-empty-tile map rooms))))
            [x y] (random-empty-tile map rooms)
            enemy {:x x :y y :hp 3}]
        (table.insert enemies enemy)
        (map:set-unit! enemy.x enemy.y enemy)))
    (print "Done generating enemies"))

  (update-hero-fov hero map)

  (global tileset (make-tileset))
  (print "Creating sprite batch...")
  (global sprite-batch (make-sprite-batch map tileset))
  (print "Done creating sprite batch")
  (global frames-graph-view (FramesGraphView:new))
  (global tile-content-view (TileContentView:new font tileset))

  (global camera-x 0)
  (global camera-y 0)
  (global camera-scale 4)
  (global dragging false)
  nil)

(lambda love.keypressed [key scancode is-repeat]
  (match (. {:left PlayerInput.LEFT
             :right PlayerInput.RIGHT
             :up PlayerInput.UP
             :down PlayerInput.DOWN}
            key)
    input (new-turn input))

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
  (love.graphics.pop)
  (love.graphics.print (.. (love.timer.getFPS) " FPS") font)
  (frames-graph-view:draw)
  (tile-content-view:draw map)
  nil)
