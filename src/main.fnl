;; TODO: rename to colors
(local Colors (require :colors))
(local FramesGraphView (require :frames-graph-view))
(local generateDungeon (require :dungeon-generator))
(local PlayerInput (require :player-input))
;; TODO: rename to random
(local Random (require :random))
(local TileKind (require :tile-kind))
(local makeTileset (require :tileset))
(local utils (require :utils))

(fn hero? [unit]
  (= unit hero))

(lambda remove-unit [unit map]
  (assert (not (hero? unit)))
  (global enemies
          (utils.filter enemies
                        (lambda [enemy] (not= enemy unit))))
  (map:set-unit! unit.x unit.y nil)
  nil)

(lambda attack [attacker victim map]
  (set victim.hp (- victim.hp 1))
  (when (= victim.hp 0)
    (assert (not (hero? victim)))
    (remove-unit victim map))
  nil)

(lambda move-unit-to [unit map x y]
  (let [tile (map:get! x y)]
    (when (tile:walkable?)
      (map:set-unit! unit.x unit.y nil)
      (set unit.x x)
      (set unit.y y)
      (map:set-unit! unit.x unit.y unit)))
  nil)

;; TODO: remove if unused
(lambda move-unit-by [unit map dx dy]
  (let [x (+ unit.x dx)
        y (+ unit.y dy)
        tile (map:get! x y)]
    (when (tile:walkable?)
      (map:set-unit! unit.x unit.y nil)
      (set unit.x (+ unit.x dx))
      (set unit.y (+ unit.y dy))
      (map:set-unit! unit.x unit.y unit)))
  nil)

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

              (if (hero? unit)
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
                    (set column 0))
                  (= tile-kind TileKind.WALL)
                  (do
                    (set row 13)
                    (set column 0))
                  (= tilekind TileKind.HALL)
                  (do
                    (set row 0)
                    (set column 2)))

              (var color nil)
              (if (= tile-kind TileKind.HALL)
                  (set color Colors.DARK-GRAY)
                  (set color (Random.random-entry
                              (utils.filter Colors.ALL
                                            (lambda [item]
                                              (not= item Colors.BLACK))))))
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

(lambda new-turn [input]
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
                    (move-unit-to hero map x y)
                    (when (not= tile.unit nil)
                      (attack hero tile.unit map))))))

  ;; TODO: only recreate the batch when something changed
  (global sprite-batch (make-sprite-batch map tileset))
  nil)

(lambda love.load []
  (love.audio.play (love.audio.newSource :assets/music/intro.mp3 :stream))
  (love.graphics.setBackgroundColor (unpack Colors.BLACK))
  (love.graphics.setDefaultFilter :nearest :nearest 0)

  (global font (love.graphics.newFont :assets/fonts/roboto/Roboto-Regular.ttf
                                      100))

  (let [(bound-map rooms) (generateDungeon 40 40)
        hero-room (Random.random-entry rooms)
        enemies-count 10]
    (global map bound-map)
    (global hero
            (let [[x y] (hero-room:random-tile)]
              {:x x :y y}))
    (map:set-unit! hero.x hero.y hero)
    (global enemies [])
    (for [i 1 enemies-count]
      (let [random-empty-tile (lambda random-empty-tile [map rooms]
                                (let [room (Random.random-entry rooms)
                                      [x y] (room:random-tile)
                                      tile (map:get! x y)]
                                  (if (tile:walkable?)
                                      [x y]
                                      (random-empty-tile map rooms))))
            [x y] (random-empty-tile map rooms)
            enemy {:x x :y y :hp 3}]
        (table.insert enemies enemy)
        (map:set-unit! enemy.x enemy.y enemy))))

  (global tileset (makeTileset))
  (global sprite-batch (make-sprite-batch map tileset))
  (global frames-graph-view (FramesGraphView:new))

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
  nil)
