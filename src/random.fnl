(let [random {}]
  (tset random :random-entry
        (lambda [t]
          (. t (love.math.random (# t)))))
  random)
