(local utils (require :utils))

(let [HashSet {}]
  (tset HashSet
        :new
        (lambda [class hash-code-func equals-func]
          (setmetatable {:%hash-code-func hash-code-func
                         :%equals-func equals-func
                         :%items {}} {:__index class})))
  (tset HashSet
        :put
        (lambda [self value]
          (let [hash (self.%hash-code-func value)]
            (when (= (. self.%items hash) nil)
              (tset self.%items hash []))

            ;; FIXME: check that the value is not already present
            (table.insert (. self.%items hash) value))
          nil))
  (tset HashSet
        :contains?
        (lambda [self value]
          (let [hash (self.%hash-code-func value)]
            (if (= (. self.%items hash) nil)
                false
                (utils.any? (. self.%items hash)
                            (lambda [item]
                              (self.%equals-func item value)))))))
  HashSet)
