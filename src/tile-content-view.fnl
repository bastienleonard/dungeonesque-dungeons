(local fonts (require :fonts))

;; TODO: don't use globals
(lambda make-camera-transform []
  (let [transform (love.math.newTransform)
        translated-transform (transform:translate camera-x camera-y)
        scaled-transform (transform:scale camera-scale camera-scale)]
    transform))

(let [TileContentView {}]
  (lambda TileContentView.new [class tileset]
    (setmetatable {:%font (fonts.get 60) :%tileset tileset} {:__index class}))
  (lambda TileContentView.draw [self map]
    (let [(mouse-x mouse-y) (love.mouse.getPosition)
          transform (make-camera-transform)
          (mouse-x mouse-y) (transform:inverseTransformPoint mouse-x mouse-y)
          tile-x (math.floor (/ mouse-x tileset.tile-width))
          tile-y (math.floor (/ mouse-y tileset.tile-height))]
      (map:get-if-valid tile-x
                        tile-y
                        (lambda [tile]
                          (let [text (: "(%s,%s)" :format tile-x tile-y)
                                width (self.%font:getWidth text)
                                height (self.%font:getHeight)
                                x (- (love.graphics.getWidth) width)
                                y 0]
                            (love.graphics.print text
                                                 self.%font
                                                 x
                                                 y)
                            (let [tile (map:get! tile-x tile-y)
                                  text (: "FOV state: %s"
                                          :format
                                          tile.fov-state)
                                  width (self.%font:getWidth text)
                                  x (- (love.graphics.getWidth) width)
                                  y (+ y height)]
                              (love.graphics.print text
                                                   self.%font
                                                   x
                                                   y)))
                          nil)))
    nil)
  TileContentView)
