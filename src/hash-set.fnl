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
