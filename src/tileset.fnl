(local colors (require :colors))
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
      (tset tileset :tile-height 16))
    (lambda tileset.color-of-tile-kind [self tile-kind]
      (match tile-kind
        TileKind.VOID colors.DARK-GRAY
        TileKind.WALL colors.LIGHT-GRAY
        TileKind.HALL colors.DARK-GRAY
        TileKind.SHELF colors.BROWN
        TileKind.SHELF-WITH-SKULL colors.BROWN
        TileKind.SKULL colors.LIGHT-GRAY
        TileKind.STAIRS-DOWN colors.PEACH
        _ (error (: "Unhandled tile kind color %s"
                    :format
                    tile-kind))))
    (lambda tileset.color-of-unit [self unit]
      (if (Unit.hero? unit)
          colors.BLUE
          colors.RED))
    tileset))
