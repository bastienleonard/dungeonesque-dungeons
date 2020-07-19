(local enum (require :enum))

(let [TileKind (enum :VOID :WALL :HALL :DECORATION)]
  (lambda TileKind.walkable? [self]
    (match self
      TileKind.VOID true
      TileKind.WALL false
      TileKind.HALL true
      TileKind.DECORATION false
      _ (error (: "Unhandled tile kind walkability %s"
                  :format
                  self))))
  (lambda TileKind.blocks-sight? [self]
    (match self
      TileKind.VOID false
      TileKind.WALL true
      TileKind.HALL false
      TileKind.DECORATION true
      _ (error (: "Unhandled tile kind blocks-sight? %s"
                  :format
                  self))))
  TileKind)
