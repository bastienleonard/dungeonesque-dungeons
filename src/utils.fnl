;; TODO: put this macro in a module
;; (fn unless [cond ...] `(when (not ,cond) ,...))

(let [utils {}]
  (fn utils.nil? [x]
    (= x nil))
  (fn utils.not-nil? [x]
    (not= x nil))
  (lambda utils.integer? [x]
    (= (math.floor x) x))
  (tset utils :array->string
        (lambda [a]
          (var s "[ ")
          (each [i item (ipairs a)]
            (set s (.. s
                       (: "%s, "
                          :format
                          (match (type item)
                            :table (utils.table->string item)
                            _ item)))))
          (set s (.. s "]"))
          s))
  (tset utils :table->string
        (lambda [t]
          (var s "{ ")
          (each [key value (pairs t)]
            (set s (.. s
                       (: "%s: %s, "
                          :format
                          key
                          (match (type value)
                            :table (utils.table->string value)
                            _ value)))))
          (set s (.. s "}"))
          s))
  (tset utils :clear-table
        (lambda [t]
          (for [i 1 (length t)]
            (table.remove t i))
          nil))
  (tset utils :dup-table
        (lambda [t]
          (let [result {}]
            (each [key value (pairs t)]
              (tset result key value))
            result)))

  (lambda utils.concat-arrays [a1 a2]
    (let [result []]
      (each [i item (ipairs a1)]
        (table.insert result item))
      (each [i item (ipairs a2)]
        (table.insert result item))
      result))

  ;; TODO: make recursive
  (tset utils :array-equals?
        (lambda [a b]
          (when (not= (length a) (length b))
              (lua "return false"))

          (each [i item (ipairs a)]
            (when (not= item (. b i))
              (lua "return false")))

          true))

  (lambda utils.array-last [array]
    (let [array-length (length array)]
      (if (= array-length 0)
          nil
          (. array array-length))))

  (lambda utils.table-contains? [t target]
    (each [key value (pairs t)]
      (when (= value target)
          (lua "return true")))
    false)

  ;; TODO: make work for "dict" tables and add imap for arrays
  (tset utils :map
        (lambda [t f]
          (let [result []]
            (each [i item (ipairs t)]
              (table.insert result (f item)))
            result)))

  ;; TODO: make work for "dict" tables and add ifilter for arrays
  (tset utils :filter
        (lambda [t f]
          (let [result []]
            (each [i item (ipairs t)]
              (when (f item)
                (table.insert result item)))
            result)))

  ;; TODO: use recursion
  (tset utils
        :any?
        (lambda [t f]
          (each [i item (ipairs t)]
            (when (f item)
              (lua "return true")))
          false))

  (lambda utils.all? [array predicate]
    (each [i item (ipairs array)]
      (when (not (predicate item))
        (lua "return false")))
    true)

  (tset utils :round
        (lambda [n] (math.floor (+ n 0.5))))
  (tset utils :with-saved-color
        (lambda [f]
          (let [previous-color [(love.graphics.getColor)]]
            (f)
            (love.graphics.setColor (unpack previous-color)))
          nil))
  utils)
