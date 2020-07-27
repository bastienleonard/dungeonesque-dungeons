(local colors (require :colors))
(local fonts (require :fonts))
(local utils (require :utils))

(local ITEM-MARGIN 100)
(local ITEM-WIDTH 100)
(local ITEM-HEIGHT 100)
(local ICON-SIZE 64)

(lambda x [inventory-length]
  (let [width (+ (* inventory-length ITEM-WIDTH)
                 (* (- inventory-length 1) ITEM-MARGIN))]
    (/ (- (love.graphics.getWidth) width) 2)))

(lambda print-above-item [x y text font]
  (love.graphics.print text
                       font
                       (+ x
                          (/ (- ITEM-WIDTH (font:getWidth text))
                             2))
                       (- y (font:getHeight)))
  nil)

(lambda print-below-item [x y text font]
  (love.graphics.print text
                       font
                       (+ x
                          (/ (- ITEM-WIDTH (font:getWidth text))
                             2))
                       (+ y ITEM-HEIGHT))
  nil)

(lambda draw-item-icon [item-kind x y]
  (let [(tile-row tile-column) (tileset:tile-of-item-kind item-kind)
        scale-x (utils.round (/ ICON-SIZE tileset.tile-width))
        scale-y (utils.round (/ ICON-SIZE tileset.tile-height))]
    (love.graphics.draw tileset.image
                        (love.graphics.newQuad (* tile-column tileset.tile-width)
                                               (* tile-row tileset.tile-height)
                                               tileset.tile-width
                                               tileset.tile-height
                                               tileset.width
                                               tileset.height)
                        x
                        y
                        0
                        scale-x
                        scale-y))
  nil)

(let [class {}]
  (lambda class.new []
    (setmetatable {} {:__index class}))
  (lambda class.draw [self inventory]
    (let [font (fonts.get 30)
          y (- (love.graphics.getHeight) ITEM-HEIGHT (font:getHeight) 1)]
      (var x (x (inventory:length)))
      (utils.with-saved-color
       (lambda []
         (each [i item (ipairs (inventory:items))]
           (love.graphics.setColor (unpack colors.WHITE))
           (print-above-item x y (tostring i) font)
           (love.graphics.rectangle :line
                                    x
                                    y
                                    ITEM-WIDTH
                                    ITEM-HEIGHT)
           (love.graphics.setColor (unpack (tileset:color-of-item-kind
                                            item.kind)))
           (draw-item-icon item.kind
                           (+ x (/ (- ITEM-WIDTH ICON-SIZE) 2))
                           (+ y (/ (- ITEM-HEIGHT ICON-SIZE) 2)))
           (love.graphics.setColor (unpack colors.WHITE))
           (print-below-item x
                             y
                             (: "%sx %s"
                                    :format
                                    item.uses
                                    (item.kind:name))
                             font)
           (set x (+ x ITEM-WIDTH ITEM-MARGIN))))))
    nil)
  class)
