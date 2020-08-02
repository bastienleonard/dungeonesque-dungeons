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

(local scaled (require :screen-scaling))
(local utils (require :utils))

(local BORDER-WIDTH 4)
(local ALPHA 1)

(lambda get-refresh-rate []
  (let [(width height flags) (love.window.getMode)]
    flags.refreshrate))

(let [FramesGraphView {}]
  (tset FramesGraphView :new
        (lambda [class]
          (let [width (scaled 500)
                instance {:width width
                          :height (scaled 300)
                          :_frame-target (math.floor
                                          (/ 1000 (get-refresh-rate)))
                          :_dts {}
                          :_dts-max (- width (* 2 BORDER-WIDTH))}]
            (setmetatable instance { :__index class })
            instance)))
  (tset FramesGraphView :update
        (lambda [self dt]
          ;; TODO: use a ring buffer
          (table.insert self._dts dt)
          (if (> (length self._dts) self._dts-max)
              (table.remove self._dts 1))
          nil))
  (tset FramesGraphView :draw
        (lambda [self]
          (let [x 0
                right (+ x self.width -1)
                y (- (love.graphics.getHeight) self.height)
                bottom (- (love.graphics.getHeight) 1)
                dt-to-y (lambda [dt]
                          (let [y (* dt 1000)
                                limit (- self.height 1 (* BORDER-WIDTH 2))]
                            (if (>= y limit)
                                limit
                                y)))]

            (utils.with-saved-color (lambda []
              (love.graphics.setColor 0 0 0 ALPHA)
              (love.graphics.rectangle :fill
                                       x
                                       y
                                       (- right x)
                                       (- bottom y))

              (love.graphics.setColor 1 1 1 ALPHA)

              (let [x-start (+ x BORDER-WIDTH)]
                (each [i dt (ipairs self._dts)]
                  (love.graphics.line (+ x-start i -1)
                                      (- bottom BORDER-WIDTH)
                                      (+ x-start i -1)
                                      (- bottom BORDER-WIDTH (dt-to-y dt)))))

              (love.graphics.setColor 1 0 0)
              (love.graphics.rectangle :fill x y self.width BORDER-WIDTH)
              (love.graphics.rectangle :fill
                                       (- right BORDER-WIDTH)
                                       y
                                       BORDER-WIDTH
                                       self.height)
              (love.graphics.rectangle :fill
                                       x
                                       (- bottom BORDER-WIDTH)
                                       self.width
                                       BORDER-WIDTH)
              (love.graphics.rectangle :fill x y BORDER-WIDTH self.height)
              (let [frame-target-y
                    (- bottom
                       (dt-to-y (/ self._frame-target 1000)))]
                (love.graphics.line x
                                    frame-target-y
                                    right
                                    frame-target-y))))
              nil)
            nil))
  FramesGraphView)
