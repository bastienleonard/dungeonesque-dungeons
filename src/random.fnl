(local utils (require :utils))

(let [random {}]
  (tset random :random-entry
        (lambda [t]
          (. t (love.math.random (length t)))))

  ;; Terrible algorithm!
  ;; TODO: use Fisher-Yates
  (lambda random.shuffled [array]
    (let [array (utils.dup-table array)]
      (for [i 1 (length array)]
        (when (= (love.math.random 1 2) 2)
          (let [j (love.math.random 1 (length array))
                copy (. array i)]
            (tset array i (. array j))
            (tset array j copy))))
      array))
  random)
