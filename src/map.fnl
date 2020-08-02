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

;; TODO: reuse two-d-array

(local utils (require :utils))
(local {:not-nil? not-nil?} (require :utils))

(lambda check-x-y! [x y]
  (assert (not-nil? x))
  (assert (not-nil? y))
  (assert (utils.integer? x) (: "%s is not an integer" :format x))
  (assert (utils.integer? y) (: "%s is not an integer" :format y)))

(lambda check-bounds! [self x y]
  (assert (>= x 0) (: "x:%s < 0" :format x))
  (assert (< x self.width) (: "x:%s >= map width %s" :format x self.width))
  (assert (>= y 0) (: "y:%s < 0" :format y))
  (assert (< y self.height) (: "y:%s >= map height %s" :format y self.height)))

(lambda orthogonal-neighbors [x y]
  [[(- x 1) y]
   [(+ x 1) y]
   [x (- y 1)]
   [x (+ y 1)]])

(lambda diagonal-neighbors [x y]
  [[(- x 1) (- y 1)]
   [(- x 1) (+ y 1)]
   [(+ x 1) (- y 1)]
   [(+ x 1) (+ y 1)]])

(let [Map {}]
  (tset Map :new
        (lambda [class options]
          ;; TODO: create a utility to handle "keyword" parameters.
          ;; It should raise an error when a mandatory parameter is not passed.
          (let [instance { :width options.width :height options.height }]
            (tset instance :_tiles
                  (let [tiles []]
                    (for [i 1 (* options.width options.height)]
                      (tset tiles i (options.make-tile)))
                    tiles))
            (setmetatable instance { :__index class })
            instance)))

  (tset Map :valid?
        (lambda [self x y]
          (check-x-y! x y)
          (and (>= x 0) (< x self.width) (>= y 0) (< y self.height))))

  (tset Map :get!
        (lambda [self x y]
          (check-x-y! x y)
          (check-bounds! self x y)
          (let [tile (. self._tiles (+ 1 x (* y self.width)))]
            (assert (not-nil? tile) (: "No tile at (%s,%s)" :format x y))
            tile)))

  (tset Map
        :get-or-nil
        (lambda [self x y]
          (check-x-y! x y)
          (if (not (self:valid? x y))
              nil
              (self:get! x y))))

  (lambda Map.get-if-valid [self x y f]
    (let [tile (self:get-or-nil x y)]
      (when (not-nil? tile)
        (f tile)))
    nil)

  (tset Map :set-unit!
        (fn [self x y unit]
          (check-x-y! x y)
          (check-bounds! self x y)
          (let [tile (self:get! x y)]
            (when (not-nil? unit)
              (assert (= tile.unit nil)))
            (set tile.unit unit))))

  (tset Map :iter
        (lambda [self]
          (var x 0)
          (var y 0)
          (var i 1)
          (lambda []
            (local tile (. self._tiles i))
            (set i (+ i 1))
            (local saved-x x)
            (local saved-y y)
            (set x (+ x 1))
            (when (= x self.width)
              (set x 0)
              (set y (+ y 1))
              (when (= y (+ self.height 1))
                (assert false)))
            (if (= tile nil)
                nil
                [saved-x saved-y tile]))))

  (tset Map
        :orthogonal-neighbors
        (lambda [self x y]
          (check-x-y! x y)
          (check-bounds! self x y)
          (let [result []]
            (each [i [x y] (ipairs (orthogonal-neighbors x y))]
              (let [tile (self:get-or-nil x y)]
                (when (not= tile nil)
                  (table.insert result [x y tile]))))
            result)))

  (lambda Map.all-neighbors [self x y]
    (check-x-y! x y)
    (check-bounds! self x y)
    (let [result []]
      (each [i [x y] (ipairs (utils.concat-arrays (orthogonal-neighbors x y)
                                                  (diagonal-neighbors x y)))]
        (let [tile (self:get-or-nil x y)]
          (when (not= tile nil)
            (table.insert result [x y tile]))))
      result))

  Map)
