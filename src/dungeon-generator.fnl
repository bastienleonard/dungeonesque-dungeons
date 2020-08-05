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

(local Map (require :map))
(local random (require :random))
(local Room (require :room))
(local Tile (require :tile))
(local TileKind (require :tile-kind))
(local utils (require :utils))

(local MIN-ROOM-WIDTH 5)
(local MAX-ROOM-WIDTH 8)
(local MIN-ROOM-HEIGHT 5)
(local MAX-ROOM-HEIGHT 8)

(fn random-tile-constrained [map predicate i]
  (assert (not= map nil))
  (assert (not= predicate nil))
  (let [x (love.math.random 0 (- map.width 1))
        y (love.math.random 0 (- map.height 1))
        tile (map:get! x y)
        i (if (= i nil) 0 i)]
    (if (> i 1000)
        nil
        (if (predicate x y tile)
            tile
            (random-tile-constrained map predicate (+ i 1))))))

(lambda place-stairs [map]
  (let [stairs-count (math.max 1
                               (math.floor (* map.width
                                              map.height
                                              0.0006)))]
    (print (: "Placing %s stairs..." :format stairs-count))
    (for [i 1 stairs-count]
      (let [tile (random-tile-constrained
                  map
                  (lambda [x y tile]
                    (and (and (= tile.unit nil)
                              (= tile.kind TileKind.VOID))
                         (utils.all? (map:all-neighbors x y)
                                     (lambda [[x y tile]]
                                       (= tile.kind TileKind.VOID))))))]
        (when (= tile nil)
          (lua :break))
        (assert (= tile.kind TileKind.VOID))
        (set tile.kind TileKind.STAIRS-DOWN)))
    (print "Done placing stairs"))
  nil)

(lambda place-chests [map]
  (let [chests-count (math.max 1
                               (math.floor (* map.width
                                              map.height
                                              0.005)))]
    (print (: "Placing %s chests..."
              :format
              chests-count))
    (for [i 1 chests-count]
      (let [tile (random-tile-constrained
                  map
                  (lambda [x y tile]
                    (and (and (= tile.unit nil)
                              (= tile.kind TileKind.VOID))
                         (utils.all? (map:all-neighbors x y)
                                     (lambda [[x y tile]]
                                       (= tile.kind TileKind.VOID))))))]
        (when (= tile nil)
          (lua :break))
        (assert (= tile.kind TileKind.VOID))
        (set tile.kind TileKind.CHEST)))
    (print "Done placing chests"))


  nil)


(lambda place-decorations [map]
  (let [decorations-count (math.max 1
                                    (math.floor (* map.width
                                                   map.height
                                                   0.01)))]
    (print (: "Placing %s decorations..." :format decorations-count))
    (for [i 1 decorations-count]
      (let [tile (random-tile-constrained
                  map
                  (lambda [x y tile]
                    (and (and (= tile.unit nil)
                              (= tile.kind TileKind.VOID))
                         (utils.all? (map:all-neighbors x y)
                                     (lambda [[x y tile]]
                                       (= tile.kind TileKind.VOID))))))]
        (when (= tile nil)
          (lua :break))
        (assert (= tile.kind TileKind.VOID))
        (set tile.kind (random.random-entry [TileKind.SHELF
                                             TileKind.SHELF-WITH-SKULL
                                             TileKind.SKULL]))))
    (print "Done placing decorations"))
  nil)

(lambda populate-dungeon [map]
  (place-stairs map)
  (place-chests map)
  (place-decorations map)
  nil)

;; TODO: support Lua's for loop
(lambda each-room-tile [room map extra f]
  (for [x
        (- room.x extra)
        (+ room.x room.width -1 extra)]
    (for [y
          (- room.y extra)
          (+ room.y room.height -1 extra)]
      (let [tile (map:get-or-nil x y)]
        (f x y tile)))))

(lambda random-room-width []
  (love.math.random MIN-ROOM-WIDTH MAX-ROOM-WIDTH))

(lambda random-room-height []
  (love.math.random MIN-ROOM-HEIGHT MAX-ROOM-HEIGHT))

(lambda random-room [map]
  (let [width (random-room-width)
        height (random-room-height)
        y (love.math.random 0 (- map.height 1 height))
        x (love.math.random 0 (- map.width 1 width))]
    (Room.new x y width height)))

(lambda room-valid? [room map]
  (var valid true)
  (each-room-tile room
                  map
                  3
                  (fn [x y tile]
                    (when (= tile nil)
                      (set valid false)
                      (lua :return))
                    (when (or (<= x 0)
                              (>= x map.width)
                              (<= y 0)
                              (>= y map.height))
                      (set valid false)
                      (lua :return))
                    (when (not= tile.kind TileKind.WALL)
                      (set valid false))))
  valid)

(lambda random-room-next-to [room direction]
  (let [[direction-x direction-y] direction
        k 3
        x (+ room.x (* direction-x k) (* direction-x room.width))
        y (+ room.y (* direction-y k) (* direction-y room.height))
        width room.width
        height room.height]
    (Room.new x y (random-room-width) (random-room-height))))

(lambda random-valid-room [map]
  (var room nil)
  (var valid false)
  (var i 0)
  ;; TODO: find a proper limit
  (while (and (not valid) (< i 1000))
    (set room (random-room map))
    (if (room-valid? room map)
        (set valid true))
    (set i (+ i 1)))
  (when (and (not valid) config.fatal-warnings?)
    (error "Failed to find a room"))
  room)

(lambda room-center [room]
  (values (math.floor (+ room.x (/ room.width 2)))
          (math.floor (+ room.y (/ room.height 2)))))

(lambda set-tile-kind [map x y kind]
  (let [tile (map:get! x y)]
    (set tile.kind kind)))

(lambda connect-tiles [map a b]
  (set-tile-kind map (. a 1) (. a 2) TileKind.VOID)
  (if (or (not= (. a 1) (. b 1))
          (not= (. a 2) (. b 2)))
      ;; TODO: improve readability with pattern matching
      (let [a (if (< (. a 1) (. b 1))
                  [(+ (. a 1) 1) (. a 2)]
                  (> (. a 1) (. b 1))
                  [(- (. a 1) 1) (. a 2)]
                  (< (. a 2) (. b 2))
                  [(. a 1) (+ (. a 2) 1)]
                  (> (. a 2) (. b 2))
                  [(. a 1) (- (. a 2) 1)]
                  (assert false
                          "Should never happen"))]
        (connect-tiles map a b))))

(lambda connect-rooms [map a b]
  (connect-tiles map
                 [(room-center a)]
                 [(room-center b)]))

(lambda [width height]
  (let [map (Map:new {:width width
                      :height height
                      :make-tile (lambda []
                                   (Tile:new {:kind TileKind.WALL}))})
        rooms-count (math.max 1 (math.floor (/ (* width
                                                  height)
                                               (* MAX-ROOM-WIDTH
                                                  MAX-ROOM-HEIGHT
                                                  1))))]
    (var previous-room (random-valid-room map))
    (assert previous-room)
    (local rooms [previous-room])
    (each-room-tile previous-room
                    map
                    0
                    (lambda [x y tile]
                      (assert tile)
                      (set tile.kind TileKind.VOID)))
    (for [i 2 rooms-count]
      (each [i direction (ipairs (random.shuffled [
                                                   [-1 0]
                                                   [1 0]
                                                   [0 -1]
                                                   [0 1]
                                                   ]))]
        (let [room (random-room-next-to previous-room direction)]
          (when (room-valid? room map)
            (var valid true)
            (each-room-tile room
                            map
                            0
                            (lambda [x y tile]
                              (assert tile)
                              (when (not= tile.kind TileKind.WALL)
                                (set valid false))))
            (when valid
              (each-room-tile room
                              map
                              0
                              (lambda [x y tile]
                                (assert tile)
                                (set tile.kind TileKind.VOID)))
              (table.insert rooms room)
              (set previous-room room)
              (lua :break))))))

    (print (: "Connecting %s rooms..."
              :format
              (length rooms)))
    (for [i 1 (- (length rooms) 1)]
      (connect-rooms map (. rooms i) (. rooms (+ i 1))))
    (print "Done connecting rooms")
    (print "Populating dungeon...")
    (populate-dungeon map)
    (print "Done populating dungeon...")
    (values map rooms)))
