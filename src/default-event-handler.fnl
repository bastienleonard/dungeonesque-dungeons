(local ItemKind (require :item-kind))
(local PlayerInput (require :player-input))
(local WandActivationEventHandler (require :wand-activation-event-handler))

(let [DefaultEventHandler {}]
  (lambda DefaultEventHandler.new [class new-turn]
    (setmetatable {:new-turn new-turn} {:__index class}))
  (lambda DefaultEventHandler.draw [self tileset]
    nil)
  (lambda DefaultEventHandler.key-pressed [self key scancode is-repeat]
    (for [i 1 9]
      (when (= key (tostring i))
        (let [item (hero.inventory:get-or-nil (- i 1))]
          (when (not= item nil)
            (match item.kind
              ItemKind.WAND (event-handlers:push
                             (WandActivationEventHandler:new
                              item
                              hero
                              (lambda []
                                (event-handlers:pop))
                              self.new-turn))
              ItemKind.POTION (do
                                (hero:heal 2)
                                (item:dec-uses)
                                (when (item:zero-uses?)
                                  (hero:remove-item item)))
              _ (error (: "Unhandled item kind %s"
                          :format
                          item.kind)))
            (lua :return)))))

    (match (. {:left PlayerInput.LEFT
               :right PlayerInput.RIGHT
               :up PlayerInput.UP
               :down PlayerInput.DOWN}
              key)
      input (self.new-turn input))
    nil)
  DefaultEventHandler)
