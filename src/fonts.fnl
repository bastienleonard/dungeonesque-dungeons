(local scaled (require :screen-scaling))

(local FONT-PATH "assets/fonts/roboto/Roboto-Regular.ttf")

(let [module {}
      cache {}]
  ;; TODO: remove and provide a few predefined sizes
  (lambda module.get [size]
    (let [size (scaled size)
          cached-font (. cache size)]
      (if (= cached-font nil)
          (let [new-font (love.graphics.newFont FONT-PATH size)]
            (print (: "Created font for size %s"
                      :format
                      size))
            (tset cache size new-font)
            new-font)
          cached-font)))
  module)
