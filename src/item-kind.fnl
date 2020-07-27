(local enum (require :enum))

(let [ItemKind (enum :FIRE-WAND :DEATH-WAND :POTION)]
  (lambda ItemKind.wand? [self]
    (or (= self ItemKind.FIRE-WAND)
        (= self ItemKind.DEATH-WAND)))
  (lambda ItemKind.name [self]
    (let [item-kind self]
      (match item-kind
        ItemKind.FIRE-WAND "fire wand"
        ItemKind.DEATH-WAND "death wand"
        ItemKind.POTION "potion"
        _ (error (: "Unhandled item kind %s name" format item-kind)))))
  ItemKind)
