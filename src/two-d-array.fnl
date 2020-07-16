(local TwoDArray {})

(lambda check-bounds! [self x y]
  (assert (>= x 0))
  (assert (< x self.width))
  (assert (>= y 0))
  (assert (< y self.height)))

(tset TwoDArray :new
      (lambda [class width height]
        (local %table [])
        (for [i 1 (* width height)]
          (tset %table i nil))
        (setmetatable {
                       :width width
                       :height height
                       :%table %table} {:__index class})))
(tset TwoDArray :get
      (lambda [self x y]
        (check-bounds! self x y)
        (. self.%table (+ 1 x (* y self.width)))))
(tset TwoDArray :set
      (lambda [self x y value]
        (check-bounds! self x y)
        (tset self.%table (+ 1 x (* y self.width)) value)))

TwoDArray
