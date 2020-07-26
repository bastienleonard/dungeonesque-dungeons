(local PlayerInput (require :player-input))
(local {:any? any?
        :concat-arrays concat-arrays
        :imap imap} (require :utils))

(let [WandActivationEventHandler {}]
  (lambda move-cursor [self dx dy]
    (let [[x y] self.%cursor-position
          new-x (+ x dx)
          new-y (+ y dy)]
      (tset self :%cursor-position [new-x new-y]))
    nil)
  (lambda WandActivationEventHandler.new [class item hero pop new-turn]
    (setmetatable {:item item
                   :%cursor-position [hero.x hero.y]
                   :pop pop
                   :new-turn new-turn}
                  {:__index class}))
  (lambda WandActivationEventHandler.draw [self tileset]
    (let [[cursor-map-x cursor-map-y] self.%cursor-position
          cursor-x (* cursor-map-x tileset.tile-width)
          cursor-y (* cursor-map-y tileset.tile-height)
          [crosshair-row crosshair-column] tileset.crosshair]
      (love.graphics.draw tileset.image
                          (love.graphics.newQuad
                           (* crosshair-row tileset.tile-width)
                           (* crosshair-column tileset.tile-height)
                           tileset.tile-width
                           tileset.tile-height
                           tileset.width
                           tileset.height)
                          cursor-x
                          cursor-y))
    nil)
  (lambda WandActivationEventHandler.key-pressed [self key scancode is-repeat]
    (if (any? (concat-arrays [:escape]
                             ;; TODO: remove hardcoding
                             (imap [1 2 3 4 5 6 7 8 9] tostring))
              (lambda [k] (= k key)))
        (self:pop)
        (any? [:return :space] #(= $1 key))
        (do
          (self:pop)
          (self.new-turn (PlayerInput:UseItem self.item
                                              self.%cursor-position)))
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
