;; Copyright 2020 Bastien Léonard. All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:

;;    1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.

;;    2. Redistributions in binary form must reproduce the above
;;    copyright notice, this list of conditions and the following
;;    disclaimer in the documentation and/or other materials provided
;;    with the distribution.

;; THIS SOFTWARE IS PROVIDED BY BASTIEN LÉONARD ``AS IS'' AND ANY
;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BASTIEN LÉONARD OR
;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
;; USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
;; OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.

(local utils (require :utils))

(fn assert= [value expected eq-func]
  (fn eq [a b]
    (if (= eq-func nil)
        (= a b)
        (eq-func a b)))
  (assert (eq value expected) (: "Value %s != %s (expected)"
                      :format
                      (utils.anything->string value)
                      (utils.anything->string expected)))
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

;; utils.array-find
(assert= (utils.array-find [] 1) nil)
(assert= (utils.array-find [1 2 3] 321) nil)
(assert= (utils.array-find [1 2 3] 1) 1)
(assert= (utils.array-find [1 2 3] 2) 2)
(assert= (utils.array-find [1 2 3] 3) 3)

;; utils.array-ordered-insert-position
(assert= (utils.array-ordered-insert-position [] 1 #(< $1 $2))
         1)
(assert= (utils.array-ordered-insert-position [1] 100 #(< $1 $2))
         2)
(assert= (utils.array-ordered-insert-position [100] 1 #(< $1 $2))
         1)
(assert= (utils.array-ordered-insert-position [2 4] 1 #(< $1 $2))
         1)
(assert= (utils.array-ordered-insert-position [2 4] 3 #(< $1 $2))
         2)
(assert= (utils.array-ordered-insert-position [2 4] 5 #(< $1 $2))
         3)
(assert= (utils.array-ordered-insert-position [-2 4] 3 #(< $1 $2))
         2)

nil
