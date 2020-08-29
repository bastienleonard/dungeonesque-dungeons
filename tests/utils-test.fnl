(local utils (require :utils))

(lambda assert= [a b]
  (assert (= a b) (: "%s != %s" :format a b))
  nil)

(each [_ [n rounded] (ipairs [[0 0]
                              [1 1]
                              [0.1 0]
                              [0.5 1]
                              [0.9 1]
                              [-0.1 0]
                              [-0.5 -1]
                              [-0.9 -1]])]
  (assert= (utils.round n) rounded))
