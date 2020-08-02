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

  (lambda utils.imap [array f]
    (utils.map array f))

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
