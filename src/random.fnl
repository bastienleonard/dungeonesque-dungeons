(let [Random {}]
  (tset Random :random-entry
        (lambda [t]
          (. t (love.math.random (# t)))))
  Random)
