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
      (tset tileset :tile-height 16))
    tileset))
