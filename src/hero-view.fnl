(local fonts (require :fonts))

(let [class []]
  (lambda class.new []
    (setmetatable {} {:__index class}))
  (lambda class.draw [self hero]
    (let [text (: "HP:  %s" :format hero.hp)
          font (fonts.get 100)
          x (- (love.graphics.getWidth) (font:getWidth text))
          y 0]
      (love.graphics.print text font x y))
    nil)
  class)
