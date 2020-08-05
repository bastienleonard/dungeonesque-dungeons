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

(local fonts (require :fonts))
(local scaled (require :screen-scaling))
(local utils (require :utils))

(local ICON-SIZE (scaled 128))

(lambda make-settings-config []
  [{:label "Fullscreen"
    :value love.window.getFullscreen
    :toggle #(love.window.setFullscreen (not (love.window.getFullscreen)))}

   ;; TODO: support adaptive sync (love.window.getVSync = -1)
   {:label "VSync"
    :value #(= (love.window.getVSync) 1)
    :toggle #(love.window.setVSync (if ($1.value)
                                       0
                                       1))}

   {:label "Show tile contents"
    :value #config.show-tile-contents?
    :toggle #(set config.show-tile-contents? (not config.show-tile-contents?))}

   {:label "FPS"
    :value #config.show-fps?
    :toggle #(set config.show-fps? (not config.show-fps?))}

   {:label "Frame durations"
    :value #config.show-frame-durations?
    :toggle #(set config.show-frame-durations?
                  (not config.show-frame-durations?))}])

(lambda print-setting [self setting y]
  (love.graphics.print setting.label font self.x y)
  (let [tile (. tileset
                (if (setting.value) :ui-checkbox-on :ui-checkbox-off))
        [tile-row tile-column] tile
        scale-x (utils.round (/ ICON-SIZE tileset.tile-width))
        scale-y (utils.round (/ ICON-SIZE tileset.tile-height))
        quad (love.graphics.newQuad (* tile-column tileset.tile-width)
                                    (* tile-row tileset.tile-height)
                                    tileset.tile-width
                                    tileset.tile-height
                                    tileset.width
                                    tileset.height)]
    (love.graphics.draw tileset.image
                        quad
                        (- self.width ICON-SIZE)
                        y
                        0
                        scale-x
                        scale-y))
  nil)

(let [class {}]
  (lambda class.new []
    (setmetatable {:x 0
                   :y 0
                   :width (love.graphics.getWidth)
                   :height (love.graphics.getHeight)
                   :%settings-config (make-settings-config)
                   :%font (fonts.get 100)}
                  {:__index class
                   :__tostring #:SettingsView}))
  (lambda class.draw [self]
    (let []
      (var y self.y)
      (love.graphics.print "Settings"
                           font
                           (/ (- self.width (font:getWidth "Settings")) 2)
                           y)
      (set y (+ y (font:getHeight)))
      (each [i setting (ipairs self.%settings-config)]
        (print-setting self setting y)
        (set y (+ y (font:getHeight)))))
    nil)
  (lambda class.mouse-pressed [self x y button is-touch presses]
    (let [font-height (self.%font:getHeight)
          header-height font-height
          y (- y self.y header-height)
          setting-height font-height
          setting-index (math.floor (/ y setting-height))
          setting-index (+ setting-index 1)
          setting (. self.%settings-config setting-index)]
      (when (not= setting nil)
        (setting:toggle setting)))
    nil)
  class)
