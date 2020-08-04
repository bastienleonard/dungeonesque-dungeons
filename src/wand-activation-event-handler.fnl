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

(local PlayerAction (require :player-action))
(local {:any? any?
        :concat-arrays concat-arrays
        :imap imap} (require :utils))
(local utils (require :utils))

(local MAX-RANGE 3)

(lambda distance [x1 y1 x2 y2]
  (utils.round (math.sqrt (+ (math.pow (- x1 x2) 2)
                             (math.pow (- y1 y2) 2)))))

(let [WandActivationEventHandler {}]
  (lambda move-cursor [self dx dy]
    (let [[x y] self.%cursor-position
          new-x (+ x dx)
          new-y (+ y dy)]
      (when (<= (distance hero.x hero.y new-x new-y) MAX-RANGE)
        (tset self :%cursor-position [new-x new-y])))
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
          (self.new-turn (PlayerAction.UseItem self.item
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
