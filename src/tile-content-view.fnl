(local fonts (require :fonts))

;; TODO: don't use globals
(lambda make-camera-transform []
  (let [transform (love.math.newTransform)
        translated-transform (transform:translate camera-x camera-y)
        scaled-transform (transform:scale camera-scale camera-scale)]
    transform))

(lambda make-coordinates [x y]
  (: "(%s,%s)" :format x y))
(lambda make-unit [tile]
  (if (= tile.unit nil)
      "No unit"
      (: "%s" :format tile.unit)))
(lambda make-lines []
  (let [(mouse-x mouse-y) (love.mouse.getPosition)
        transform (make-camera-transform)
        (mouse-x mouse-y) (transform:inverseTransformPoint mouse-x mouse-y)
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
    (var y 0)
    (each [i line (ipairs (make-lines))]
      (print-line line y self.%font)
      (set y (+ y (self.%font:getHeight))))
    nil)
  TileContentView)
