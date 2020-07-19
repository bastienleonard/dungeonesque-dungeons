(local FovState (require :fov-state))
(local TileKind (require :tile-kind))

(lambda tile->string [self]
  (: "Tile kind=%s walkable?=%s"
     :format
     self.kind
     (self:walkable?)))

(let [Tile {}]
  (tset Tile :new
        (lambda [class options]
          (let [instance {:kind (or options.kind TileKind.VOID)
                          :fov-state FovState.UNEXPLORED}]
            (setmetatable instance
                          {:__index class
                           :__tostring tile->string})
            instance)))
  (tset Tile :walkable?
        (lambda [self]
          (let [kind self.kind]
            (and (= self.unit nil)
                 (kind:walkable?)))))
  (lambda Tile.blocks-sight? [self]
    (self.kind:blocks-sight?))
  Tile)
