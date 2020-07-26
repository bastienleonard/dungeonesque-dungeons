(local enum (require :enum))

(let [ItemKind (enum :FIRE-WAND :DEATH-WAND :POTION)]
  (lambda ItemKind.wand? [self]
    (or (= self ItemKind.FIRE-WAND)
        (= self ItemKind.DEATH-WAND)))
  ItemKind)
