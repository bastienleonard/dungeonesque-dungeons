(local PlayerInput (require :player-input))
(local WandActivationEventHandler (require :wand-activation-event-handler))

;; TODO: handler methods should not depend on LOVE2D
(let [DefaultEventHandler {}]
  (lambda DefaultEventHandler.new [class new-turn]
    (setmetatable {:new-turn new-turn} {:__index class}))
  (lambda DefaultEventHandler.draw [self tileset]
    nil)
  (lambda DefaultEventHandler.key-pressed [self key scancode is-repeat]
    (for [i 1 9]
      (when (= key (tostring i))
        (event-handlers:push
         (WandActivationEventHandler:new hero
                                         (lambda []
                                           (event-handlers:pop))
                                         self.new-turn))
        (lua :return)))

    (match (. {:left PlayerInput.LEFT
               :right PlayerInput.RIGHT
               :up PlayerInput.UP
               :down PlayerInput.DOWN}
              key)
      input (self.new-turn input))
    nil)
  DefaultEventHandler)
