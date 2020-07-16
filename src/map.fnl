;; TODO: reuse two-d-array

(local utils (require :utils))
(local {:not-nil? not-nil?} (require :utils))

(lambda check-x-y! [x y]
  (assert (not-nil? x))
  (assert (not-nil? y))
  (assert (utils.integer? x) (: "%s is not an integer" :format x))
  (assert (utils.integer? y) (: "%s is not an integer" :format y)))

(lambda check-bounds! [self x y]
  (assert (>= x 0))
  (assert (< x self.width))
  (assert (>= y 0))
  (assert (< y self.height)))

(let [Map {}]
  (tset Map :new
        (lambda [class options]
          ;; TODO: create a utility to handle "keyword" parameters.
          ;; It should raise an error when a mandatory parameter is not passed.
          (let [instance { :width options.width :height options.height }]
            (tset instance :_tiles
                  (let [tiles []]
                    (for [i 1 (* options.width options.height)]
                      (tset tiles i (options.make-tile)))
                    tiles))
            (setmetatable instance { :__index class })
            instance)))

  (tset Map :valid?
        (lambda [self x y]
          (check-x-y! x y)
          (and (>= x 0) (< x self.width) (>= y 0) (< y self.height))))

  (tset Map :get!
        (lambda [self x y]
          (check-x-y! x y)
          (check-bounds! self x y)
          (let [tile (. self._tiles (+ 1 x (* y self.width)))]
            (assert (not-nil? tile) (: "No tile at (%s,%s)" :format x y))
            tile)))

  (tset Map
        :get-or-nil
        (lambda [self x y]
          (check-x-y! x y)
          (if (not (map:valid? x y))
              nil
              (self:get! x y))))

  (lambda Map.get-if-valid [self x y f]
    (let [tile (self:get-or-nil x y)]
      (when (not-nil? tile)
        (f tile)))
    nil)

  (tset Map :set-unit!
        (fn [self x y unit]
          (check-x-y! x y)
          (check-bounds! self x y)
          (let [tile (self:get! x y)]
            (when (not-nil? unit)
              (assert (= tile.unit nil)))
            (set tile.unit unit))))

  ;; TODO: support Lua's for loop
  (tset Map :iter
        (lambda [self f]
          (var x 0)
          (var y 0)
          (each [i tile (ipairs self._tiles)]
            (f x y tile)
            (set x (+ x 1))
            (if (= x self.width)
                (do
                  (set x 0)
                  (set y (+ y 1))
                  (if (= y (+ self.height 1))
                      (assert false)))))
          nil))
  Map)
