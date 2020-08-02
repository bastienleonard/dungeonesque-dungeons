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

(let [class {}]
  (lambda class.new []
    (setmetatable {:%items []} {:__index class}))
  (lambda class.add [self item]
    (each [i current (ipairs self.%items)]
      (when (= current.kind item.kind)
        (current:inc-uses)
        (lua :return)))

    (table.insert self.%items item)
    nil)
  (lambda class.remove [self item]
    (for [i 1 (length self.%items)]
      (when (= (. self.%items i) item)
        (table.remove self.%items i)
        (lua :return)))

    (error)
    nil)

  ;; position is 0-based
  (lambda class.get! [self position]
    (when (or (< position 0) (>= position (self:length)))
      (error (: "Position %s is out of bounds for item with length %s"
                :format
                position
                (self:length))))

    (. self.%items (+ position 1)))

  ;; position is 0-based
  (lambda class.get-or-nil [self position]
    (if (or (< position 0) (>= position (self:length)))
        nil
        (. self.%items (+ position 1))))

  (lambda class.length [self]
    (length self.%items))
  (lambda class.items [self]
    self.%items)
  class)
