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

(lambda unit-statuses->string [self]
  (if (utils.table-empty? self.%statuses)
      "[]"
      (utils.join (utils.map self.%statuses
                             (lambda [status turns]
                               (: "%s (%s turns)"
                                  :format
                                  status
                                  turns)))
                  ", ")))

(let [class {}]
  (lambda class.new []
    (setmetatable {:%statuses {}}
                  {:__index class
                   :__tostring unit-statuses->string}))

  (lambda class.turn-elapsed [self]
    (each [status turns (pairs (utils.dup-table self.%statuses))]
      (let [new-turns (- turns 1)]
        (tset self.%statuses status (if (<= new-turns 0)
                                        nil
                                        new-turns))))
    nil)

  (lambda class.has? [self status]
    (each [current-status turns (pairs self.%statuses)]
      (when (and (= current-status status)
                 (> turns 0))
        (lua "return true")))
    false)

  (lambda class.add [self status turns]
    (if (= (. self.%statuses status) nil)
        (tset self.%statuses status turns)
        (tset self.%statuses status (+ (. self.%statuses status) turns)))
    nil)

  class)
