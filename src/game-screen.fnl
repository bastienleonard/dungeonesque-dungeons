(local HeroView (require :hero-view))

(let [class {}]
  (lambda class.new []
    (setmetatable {:%hero-view (HeroView.new)}
                  {:__index class
                   :__tostring (lambda [self] "GameScreen")}))
  (lambda class.draw [self]
    (love.graphics.push)
    (love.graphics.translate camera-x camera-y)
    (love.graphics.scale camera-scale camera-scale)
    (love.graphics.draw sprite-batch)
    (: (event-handlers:current) :draw tileset)
    (love.graphics.pop)
    (inventory-view:draw hero.inventory)
    (when config.dev-mode?
      (tile-content-view:draw map))
    (self.%hero-view:draw hero)
    nil)
  class)
