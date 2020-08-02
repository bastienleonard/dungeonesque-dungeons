(lambda room->string [self]
  (: "Room x=%s y=%s width=%s height=%s"
     :format
     self.x
     self.y
     self.width
     self.height))

(let [class {}]
  (lambda class.new [x y width height]
    (setmetatable {:x x
                   :y y
                   :width width
                   :height height}
                  {:__index class
                   :__tostring room->string}))
  (lambda class.random-tile [self]
    [(love.math.random (+ self.x 1)
                       (+ self.x
                          1
                          (math.floor (/ self.width 2))))
     (love.math.random (+ self.y 1)
                       (+ self.y 1
                          (math.floor (/ self.height 2))))])
  (lambda class.right [self]
    (+ self.x self.width))
  (lambda class.bottom [self]
    (+ self.y self.height))
  class)
