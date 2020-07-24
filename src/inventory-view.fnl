(local colors (require :colors))
(local fonts (require :fonts))
(local utils (require :utils))

(local ITEM-MARGIN 100)
(local ITEM-WIDTH 100)
(local ITEM-HEIGHT 100)

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

(let [class {}]
  (lambda class.new []
    (setmetatable {} {:__index class}))
  (lambda class.draw [self inventory]
    (let [y (- (love.graphics.getHeight) ITEM-HEIGHT 1)
          font (fonts.get 30)]
      (var x (x (inventory:length)))
      (utils.with-saved-color (lambda []
                                (love.graphics.setColor (unpack colors.WHITE))
                                (each [i item (ipairs (inventory:items))]
                                  (print-above-item x y (tostring i) font)
                                  (love.graphics.rectangle :line
                                                           x
                                                           y
                                                           ITEM-WIDTH
                                                           ITEM-HEIGHT)
                                  (set x (+ x ITEM-WIDTH ITEM-MARGIN))))))
    nil)
  class)
