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

(local Inventory (require :inventory))

(lambda unit->string [self]
  (: "Unit x=%s y=%s hp=%s fov-range=%s"
     :format
     self.x
     self.y
     self.hp
     self.fov-range))

(let [class {}]
  (fn class.hero? [unit]
    (= unit hero))
  (lambda class.new [x y hp fov-range]
    (setmetatable {:x x
                   :y y
                   :hp hp
                   :fov-range fov-range
                   :inventory (Inventory.new)}
                  {:__index class
                   :__tostring unit->string}))
  (lambda class.dead? [self]
    (<= self.hp 0))
  (lambda class.heal [self amount]
    (set self.hp (+ self.hp amount))
    nil)
  (lambda class.damage [self amount]
    (set self.hp (- self.hp amount))
    (if (self:dead?)
        :death
        :survival))
  (lambda class.give-item [self item]
    (self.inventory:add item)
    nil)
  (lambda class.remove-item [self item]
    (self.inventory:remove item)
    nil)
  class)
