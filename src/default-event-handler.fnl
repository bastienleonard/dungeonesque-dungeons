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

(local ItemKind (require :item-kind))
(local PlayerInput (require :player-input))
(local WandActivationEventHandler (require :wand-activation-event-handler))

(lambda handle-wand [self item]
  (event-handlers:push (WandActivationEventHandler:new item
                                                       hero
                                                       (lambda []
                                                         (event-handlers:pop))
                                                       self.new-turn))
  nil)

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
              (wand ? (ItemKind.wand? wand)) (handle-wand self
                                                          item)
              ItemKind.POTION (self.new-turn (PlayerInput:UseItem item))
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
