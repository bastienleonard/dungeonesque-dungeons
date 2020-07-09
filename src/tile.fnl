(local TileKind (require :tile-kind))

(lambda tile->string [self]
  (: "Tile kind=%s walkable?=%s"
     :format
     self.kind
     (self:walkable?)))

(let [Tile {}]
  (tset Tile :new
        (lambda [class options]
          (let [instance {:kind (or options.kind TileKind.VOID)}]
            (if (= (love.math.random 10) 10)
                (tset instance :kind TileKind.WALL)
                (tset instance :unit options.unit))
            (setmetatable instance
                          {:__index class
                           :__tostring tile->string})
            instance)))
  (tset Tile :walkable?
        (lambda [self]
          (let [kind self.kind]
            (if (not= self.unit nil)
                false
                (match kind
                  TileKind.VOID true
                  TileKind.WALL false
                  TileKind.HALL true
                  _ (assert false
                            (: "Unhandled tile kind %s" :format kind)))))))
  Tile)
