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

(local colors (require :colors))
(local ItemKind (require :item-kind))
(local random (require :random))
(local TileKind (require :tile-kind))
(local Unit (require :unit))
(local utils (require :utils))

(local IMAGE-PATH :assets/tilesets/kenney-1-bit/tileset-monochrome-transparent-no-borders.png)

;; Instead of creating the tileset now, we return a function. This prevents the
;; image from being blurry because of creating the image before calling
;; love.graphics.setDefaultFilter('nearest', 'nearest', 0).
(lambda []
  (let [tileset {}]
    (let [image (love.graphics.newImage IMAGE-PATH)]
      (tset tileset :image image)
      (tset tileset :width (image:getWidth))
      (tset tileset :height (image:getHeight))
      (tset tileset :tile-count (* 32 32))
      (tset tileset :tile-width 16)
      (tset tileset :tile-height 16)
      ;; The row and column of the crosshair tile
      (tset tileset :crosshair [22 14])
      (tset tileset :ui-checkbox-on [15 23])
      (tset tileset :ui-checkbox-off [15 24]))
    (lambda tileset.color-of-tile-kind [self tile-kind]
      (match tile-kind
        TileKind.VOID colors.DARK-GRAY
        TileKind.WALL colors.LIGHT-GRAY
        TileKind.HALL colors.DARK-GRAY
        TileKind.SHELF colors.BROWN
        TileKind.SHELF-WITH-SKULL colors.BROWN
        TileKind.SKULL colors.LIGHT-GRAY
        TileKind.CHEST colors.BROWN
        TileKind.STAIRS-DOWN colors.PEACH
        _ (error (: "Unhandled tile kind color %s"
                    :format
                    tile-kind))))
    (lambda tileset.color-of-unit [self unit]
      (if (Unit.hero? unit)
          colors.BLUE
          colors.RED))
    (lambda tileset.tile-of-item-kind [self item-kind]
      (match item-kind
        ItemKind.FIRE-WAND (values 27 1)
        ItemKind.DEATH-WAND (values 27 2)
        ItemKind.ICE-WAND (values 26 1)
        ItemKind.POTION (values 23 25)
        _ (error (: "Unhandled item kind %s tile"
                    :format
                    item-kind))))
    (lambda tileset.color-of-item-kind [self item-kind]
      (match item-kind
        ItemKind.FIRE-WAND colors.ORANGE
        ItemKind.DEATH-WAND colors.YELLOW
        ItemKind.ICE-WAND colors.BLUE
        ItemKind.POTION colors.RED
        _ (error (: "Unhandled item kind %s color"
                    :format
                    item-kind))))
    tileset))
