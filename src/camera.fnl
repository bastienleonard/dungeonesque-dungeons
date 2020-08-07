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

(lambda make-transform [self]
  (let [transform (love.math.newTransform)
        translated-transform (transform:translate self.%x self.%y)
        scaled-transform (transform:scale self.%scale self.%scale)]
    transform))

(let [class {}]
  (lambda class.new []
    (setmetatable {:%x 0
                   :%y 0
                   :%scale 4}
                  {:__index class}))
  (lambda class.translate [self dx dy]
    (set self.%x (+ self.%x dx))
    (set self.%y (+ self.%y dy))
    nil)
  (lambda class.scale [self factor]
    (set self.%scale (* self.%scale factor))
    nil)
  (lambda class.center-on-map-tile [self x y tileset]
    (set self.%x (- (/ (love.graphics.getWidth) 2)
                    (* x tileset.tile-width self.%scale)))
    (set self.%y (- (/ (love.graphics.getHeight) 2)
                    (* y tileset.tile-height self.%scale)))
    nil)
  (lambda class.apply-transform [self]
    (love.graphics.translate self.%x self.%y)
    (love.graphics.scale self.%scale self.%scale)
    nil)
  (lambda class.inverse-transform [self x y]
    (: (make-transform self) :inverseTransformPoint x y))
  class)
