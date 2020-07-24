(local enum (require :enum))

(let [TileKind (enum :VOID
                     :WALL
                     :HALL
                     :SHELF
                     :SHELF-WITH-SKULL
                     :SKULL
                     :CHEST
                     :STAIRS-DOWN)]
  (lambda TileKind.walkable? [self]
    (match self
      TileKind.VOID true
      TileKind.WALL false
      TileKind.HALL true
      TileKind.SHELF false
      TileKind.SHELF-WITH-SKULL false
      TileKind.SKULL false
      TileKind.CHEST true
      TileKind.STAIRS-DOWN true
      _ (error (: "Unhandled tile kind walkability %s"
                  :format
                  self))))
  (lambda TileKind.blocks-sight? [self]
    (match self
      TileKind.VOID false
      TileKind.WALL true
      TileKind.HALL false
      TileKind.SHELF true
      TileKind.SHELF-WITH-SKULL true
      TileKind.SKULL true
      TileKind.CHEST false
      TileKind.STAIRS-DOWN false
      _ (error (: "Unhandled tile kind blocks-sight? %s"
                  :format
                  self))))
  TileKind)
