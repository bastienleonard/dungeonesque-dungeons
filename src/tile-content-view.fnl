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

(lambda make-coordinates [x y]
  (: "(%s,%s)" :format x y))
(lambda make-unit [tile]
  (if (= tile.unit nil)
      "No unit"
      (: "%s" :format tile.unit)))
(lambda make-lines []
  (let [(mouse-x mouse-y) (love.mouse.getPosition)
        (mouse-x mouse-y) (camera:inverse-transform mouse-x mouse-y)
        tile-x (math.floor (/ mouse-x tileset.tile-width))
        tile-y (math.floor (/ mouse-y tileset.tile-height))
        tile (map:get-or-nil tile-x tile-y)
        coordinates (if (= tile nil) "" (make-coordinates tile-x tile-y))
        unit (if (= tile nil) "" (make-unit tile))]
    [coordinates unit]))

(lambda print-line [line y font]
  (let [x (- (love.graphics.getWidth) (font:getWidth line))]
    (love.graphics.print line font x y))
  nil)

(let [TileContentView {}]
  (lambda TileContentView.new [class tileset]
    (setmetatable {:%font (fonts.get 60) :%tileset tileset} {:__index class}))
  (lambda TileContentView.draw [self map]
    (let [lines (make-lines)
          font self.%font]
      (var y (- (love.graphics.getHeight) (* (length lines) (font:getHeight))))
      (each [i line (ipairs lines)]
        (print-line line y font)
        (set y (+ y (self.%font:getHeight)))))
    nil)
  TileContentView)
