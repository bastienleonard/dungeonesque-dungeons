(local utils (require :utils))

(fn assert= [a b eq-func]
  (assert (not= a nil))
  (assert (not= b nil))
  (lambda eq [a b]
    (if (= eq-func nil)
        (= a b)
        (eq-func a b)))
  (assert (eq a b) (: "%s != %s" :format a b))
  nil)

;; utils.round
(each [_ [n rounded] (ipairs [[0 0]
                              [1 1]
                              [0.1 0]
                              [0.5 1]
                              [0.9 1]
                              [-0.1 0]
                              [-0.5 -1]
                              [-0.9 -1]])]
  (assert= (utils.round n) rounded))

;; utils.array-sorted
(assert= (utils.array-sorted [2 1]) [1 2] utils.table=)
(assert= (utils.array-sorted [1 2 3 4 5]) [1 2 3 4 5] utils.table=)
(assert= (utils.array-sorted [5 4 3 2 1]) [1 2 3 4 5] utils.table=)
(assert= (utils.array-sorted [2 9 2 5 0 3 4 7 0 4])
         [0 0 2 2 3 4 4 5 7 9]
         utils.table=)
(assert= (utils.array-sorted [-7 -8 -1 3 -9 4 6 -5 -7 -6])
         [-9 -8 -7 -7 -6 -5 -1 3 4 6]
         utils.table=)
(assert= (utils.array-sorted [-7 -8 -1 3 -9 4 6 -5 -7 -6]
                             #(< $1 $2))
         [-9 -8 -7 -7 -6 -5 -1 3 4 6]
         utils.table=)

nil
