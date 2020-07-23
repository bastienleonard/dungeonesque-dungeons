(local PlayerInput (require :player-input))

(let [WandActivationEventHandler {}]
  (lambda move-cursor [self dx dy]
    (let [[x y] self.%cursor-position
          new-x (+ x dx)
          new-y (+ y dy)]
      (tset self :%cursor-position [new-x new-y]))
    nil)
  (lambda WandActivationEventHandler.new [class hero pop new-turn]
    (setmetatable {:%cursor-position [hero.x hero.y]
                   :pop pop
                   :new-turn new-turn} {:__index class}))
  (lambda WandActivationEventHandler.draw [self tileset]
    (let [[cursor-map-x cursor-map-y] self.%cursor-position
          cursor-x (* cursor-map-x tileset.tile-width)
          cursor-y (* cursor-map-y tileset.tile-height)]
      (love.graphics.draw tileset.image
                          (love.graphics.newQuad
                           ;; TODO: delegate to Tileset
                           (* 22 tileset.tile-width)
                           (* 14 tileset.tile-height)
                           tileset.tile-width
                           tileset.tile-height
                           tileset.width
                           tileset.height)
                          cursor-x
                          cursor-y))
    nil)
  (lambda WandActivationEventHandler.key-pressed [self
                                                  key
                                                  scancode
                                                  is-repeat]
    (if (= key :return)
        (do
          (self:pop)
          (self.new-turn (PlayerInput:UseItem self.%cursor-position)))
        (do
          (let [[dx dy] (match key
                          :left [-1 0]
                          :right [1 0]
                          :up [0 -1]
                          :down [0 1]
                          _ [0 0])]
            (move-cursor self dx dy))))
    nil)
  WandActivationEventHandler)
