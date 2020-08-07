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

(local HashSet (require :hash-set))
(local TileKind (require :tile-kind))
(local TwoDArray (require :two-d-array))
(local utils (require :utils))

(lambda neighbors [x y map]
  (let [result []]
    (each [i [dx dy] (ipairs [[-1 0]
                              [0 -1]
                              [0 1]
                              [1 0]])]
      (let [x (+ x dx) y (+ y dy)]
        (when (map:valid? x y)
          (let [tile (map:get! x y)]
            (when (tile.kind:walkable?)
              (table.insert result [x y]))))))
    result))

;; TODO: test performance with ArraySet
(lambda shortest-path [from to map]
  (local visited (HashSet:new (lambda [point]
                                ;; FIXME: generate a non stupid hash code
                                (let [[x y] point]
                                  (assert (< y 10000))
                                  (+ (* x 10000) y)))
                              (lambda [a b]
                                (utils.array-equals? a b))))
  (local to-visit [])

  (local parents (TwoDArray:new map.width map.height))

  (table.insert to-visit from)

  (while (> (length to-visit) 0)
    (local [x y] (table.remove to-visit 1))

    (each [i neighbor (ipairs (neighbors x y map))]
      (when (not (visited:contains? neighbor))
        (visited:put neighbor)
        (table.insert to-visit neighbor)
        (parents:set (. neighbor 1) (. neighbor 2) [x y]))))

  (let [path []]
    (var current to)
    (while (not (utils.array-equals? current from))
      (table.insert path 1 current)
      (let [[current-x current-y] current]
        (set current (parents:get current-x current-y)))

      (when (= current nil)
        (let [message (: (.. "Warning: failed to find path from %s to %s "
                             "with path length %s\n")
                         :format
                         (utils.array->string from)
                         (utils.array->string to)
                         (length path))]
          (if config.fatal-warnings?
              (error message)
              (do
                (io.stderr:write message)
                (lua "return nil"))))))
    path))
