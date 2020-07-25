(local fonts (require :fonts))

(let [class {}]
  (lambda class.new []
    (setmetatable {} {:__index class}))
  (lambda class.draw [self]
    (let [font (fonts.get 100)
          text "You died"
          x (/ (- (love.graphics.getWidth) (font:getWidth text)) 2)
          y (/ (- (love.graphics.getHeight) (font:getHeight)) 2)]
      (love.graphics.print text font x y))
    nil)
  class)
