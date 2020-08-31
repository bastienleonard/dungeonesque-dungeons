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

(let [module {}]
  (fn module.anything->string [x]
    (if (= (type x) :table)
        (module.table->string x)
        (tostring x)))

  (fn module.nil? [x]
    (= x nil))

  (fn module.not-nil? [x]
    (not= x nil))

  (lambda module.integer? [x]
    (= (math.floor x) x))

  (lambda module.array->string [a]
    (var s "[ ")

    (each [i item (ipairs a)]
      (set s (.. s
                 (: "%s, "
                    :format
                    (match (type item)
                      :table (module.table->string item)
                      _ item)))))

    (set s (.. s "]"))
    s)

  (lambda module.array-find [array item]
    (var result nil)

    (each [i current (ipairs array)]
      (when (= current item)
        (set result i)
        (lua :break)))

    result)

  (lambda module.array-shift-right! [array]
    (when (= (length array) 0)
      (lua :return))

    (local previous-length (length array))

    (for [i (+ (length array) 1) 2]
      (tset array i (. array (- i 1))))

    (tset array 1 nil)
    (assert (= (length array) (+ previous-length 1)))
    nil)

  (lambda module.array-ordered-insert-position [array item comp]
    (var position nil)

    (for [i 1 (length array)]
      (let [current (. array i)]
        (when (comp item current)
          (set position i)
          (lua :break))))

    (when (= position nil)
      (set position (+ (length array) 1)))

    (when (= position 0)
      (set position 1))

    position)

  (lambda module.array-insert-in-order [array item comp]
    (table.insert array
                  (module.array-ordered-insert-position array item comp)
                  item)
    nil)

  (lambda module.table->string [t]
    (var s "{ ")

    (each [key value (pairs t)]
      (set s (.. s
                 (: "%s: %s, "
                    :format
                    key
                    (match (type value)
                      :table (if (. (getmetatable value) :__tostring)
                                 (tostring value)
                                 (module.table->string value))
                      _ value)))))

    (set s (.. s "}"))
    s)

  (lambda module.clear-table [t]
    (for [i 1 (length t)]
      (table.remove t i))
    nil)

  (lambda module.dup-table [t]
    (let [result {}]
      (each [key value (pairs t)]
        (tset result key value))
      result))

  (lambda module.concat-arrays [a1 a2]
    (let [result []]
      (each [i item (ipairs a1)]
        (table.insert result item))

      (each [i item (ipairs a2)]
        (table.insert result item))

      result))

  ;; TODO: remove and use table=
  (lambda module.array-equals? [a b]
    (when (not= (length a) (length b))
      (lua "return false"))

    (each [i item (ipairs a)]
      (when (not= item (. b i))
        (lua "return false")))

    true)

  (lambda module.array-last [array]
    (let [array-length (length array)]
      (if (= array-length 0)
          nil
          (. array array-length))))

  (lambda module.table-keys [t]
    (let [result []]
      (each [key value (pairs t)]
        (table.insert result key))
      result))

  (lambda module.table-values [t]
    (var result [])

    (each [key value (pairs t)]
      (table.insert result value))

    result)

  (lambda module.table-contains? [t target]
    (each [key value (pairs t)]
      (when (= value target)
          (lua "return true")))
    false)

  (lambda module.table-empty? [t]
    (each [key value (pairs t)]
      (lua "return false"))
    true)

  (lambda module.table= [a b]
    (when (not= (length a) (length b))
      (lua "return false"))

    (each [key value (pairs a)]
      (when (not= value (. b key))
        (lua "return false")))

    true)

  (lambda module.imap [array f]
    (let [result []]
      (each [i item (ipairs array)]
        (table.insert result (f item)))
      result))

  (lambda module.map [t f]
    (let [result []]
      (each [key value (pairs t)]
        (table.insert result (f key value)))
      result))

  (lambda module.ifilter [array predicate]
    (let [result []]
      (each [i item (ipairs array)]
        (when (predicate item)
          (table.insert result item)))
      result))

  (lambda module.iany? [array f]
    (each [i item (ipairs array)]
      (when (f item)
        (lua "return true")))
    false)

  (lambda module.all? [array predicate]
    (each [i item (ipairs array)]
      (when (not (predicate item))
        (lua "return false")))
    true)

  (lambda module.round [n]
    (if (< n 0)
        (math.ceil (- n 0.5))
        (math.floor (+ n 0.5))))

  (lambda module.join [array delimiter]
    (var result "")

    (each [i item (ipairs array)]
      (set result (.. result item))
      (when (< i (length array))
        (set result (.. result delimiter))))

    result)

  (fn module.array-sorted [array cmp]
    (assert (not= array nil))

    (let [copy (module.dup-table array)]
      (table.sort copy cmp)
      copy))

  module)
