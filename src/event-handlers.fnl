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

(let [class {}]
  (lambda class.new []
    (setmetatable {:%handlers []} {:__index class}))

  (lambda class.any? [self]
    (> (length self.%handlers) 0))

  (lambda class.current [self]
    (when (not (self:any?))
      (error "No event handler registered"))
    (utils.array-last self.%handlers))

  (lambda class.push [self handler]
    (table.insert self.%handlers handler)
    nil)

  (lambda class.pop [self]
    (let [handlers-length (length self.%handlers)]
      (when (= handlers-length 0)
        (error "Can't pop event handler with no handlers registered"))
      (table.remove self.%handlers handlers-length))

    nil)

  class)
