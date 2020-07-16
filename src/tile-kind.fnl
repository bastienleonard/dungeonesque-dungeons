(local enum (require :enum))

(let [TileKind (enum :VOID :WALL :HALL)]
  (lambda TileKind.walkable? [self]
    (match self
      TileKind.VOID true
      TileKind.WALL false
      TileKind.HALL true
      _ (assert false)))
  TileKind)
