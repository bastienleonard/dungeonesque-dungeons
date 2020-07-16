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
      (assert current))
    path))
