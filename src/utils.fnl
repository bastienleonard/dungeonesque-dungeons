;; TODO: put this macro in a module
;; (fn unless [cond ...] `(when (not ,cond) ,...))

(let [utils {}]
  (tset utils :table->string
        (lambda [t]
          (var s "{ ")
          (each [key value (pairs t)]
            (set s (.. s
                       (: "%s: %s"
                          :format
                          key
                          value)
                       ", ")))
          (set s (.. s "}"))
          s))
  (tset utils :map
        (lambda [t f]
          (let [result []]
            (each [i item (ipairs t)]
              (table.insert result (f item)))
            result)))
  (tset utils :filter
        (lambda [t f]
          (let [result []]
            (each [i item (ipairs t)]
              (when (f item)
                (table.insert result item)))
            result)))
  (tset utils :round
        (lambda [n] (math.floor (+ n 0.5))))
  (tset utils :with-saved-color
        (lambda [f]
          (let [previous-color [(love.graphics.getColor)]]
            (f)
            (love.graphics.setColor (unpack previous-color)))
          nil))
  utils)
