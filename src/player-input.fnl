(let [PlayerInput {}]
  (each [i name (ipairs [:LEFT :RIGHT :UP :DOWN])]
    (tset PlayerInput
          name
          (setmetatable {:kind :move} {:__index PlayerInput
                                       :__tostring (lambda [self] name)})))
  (lambda PlayerInput.UseItem [class item target]
    (setmetatable {:kind :item-use
                   :item item
                   :target target}
                  {:__index class
                   :__tostring (lambda [self]
                                 (: "UseItem %s" :format self.item))}))
  PlayerInput)
