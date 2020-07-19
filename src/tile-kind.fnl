(local enum (require :enum))

(let [TileKind (enum :VOID :WALL :HALL :DECORATION :STAIRS-DOWN)]
  (lambda TileKind.walkable? [self]
    (match self
      TileKind.VOID true
      TileKind.WALL false
      TileKind.HALL true
      TileKind.DECORATION false
      TileKind.STAIRS-DOWN true
      _ (error (: "Unhandled tile kind walkability %s"
                  :format
                  self))))
  (lambda TileKind.blocks-sight? [self]
    (match self
      TileKind.VOID false
      TileKind.WALL true
      TileKind.HALL false
      TileKind.DECORATION true
      TileKind.STAIRS-DOWN false
      _ (error (: "Unhandled tile kind blocks-sight? %s"
                  :format
                  self))))
  TileKind)
