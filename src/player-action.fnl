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

(let [PlayerAction {}
      MOVE-NAMES [:MOVE-LEFT :MOVE-RIGHT :MOVE-UP :MOVE-DOWN]]
  (each [i name (ipairs MOVE-NAMES)]
    (tset PlayerAction
          name
          (setmetatable {:move? #true}
                        {:__index PlayerAction
                         :__tostring (lambda [self] name)})))

  (lambda PlayerAction.move? [self]
    false)

  (lambda PlayerAction.item-use? [self]
    false)

  (fn PlayerAction.UseItem [item target]
    (assert (not= item nil))
    (setmetatable {:item item
                   :target target
                   :item-use? #true}
                  {:__index PlayerAction
                   :__tostring (lambda [self]
                                 (: "UseItem %s" :format self.item))}))

  PlayerAction)
