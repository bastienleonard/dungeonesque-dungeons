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
          (and (>= x 0) (< x self.width) (>= y 0) (< y self.height))))

  (tset Map :get!
        (lambda [self x y]
          (let [tile (. self._tiles (+ 1 x (* y self.width)))]
            (assert (~= tile nil) (: "No tile at %d,%d" :format x y))
            tile)))

  (tset Map :set-unit!
        (fn [self x y unit]
          (assert (not= x nil))
          (assert (not= y nil))
          (let [tile (self:get! x y)]
            (when (not= unit nil)
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
