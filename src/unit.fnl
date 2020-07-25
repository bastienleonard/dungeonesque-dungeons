(local Inventory (require :inventory))

(lambda unit->string [self]
  (: "Unit x=%s y=%s hp=%s fov-range=%s"
     :format
     self.x
     self.y
     self.hp
     self.fov-range))

(let [class {}]
  (fn class.hero? [unit]
    (= unit hero))
  (lambda class.new [x y hp fov-range]
    (setmetatable {:x x
                   :y y
                   :hp hp
                   :fov-range fov-range
                   :inventory (Inventory.new)}
                  {:__index class
                   :__tostring unit->string}))
  (lambda class.dead? [self]
    (<= self.hp 0))
  (lambda class.heal [self amount]
    (set self.hp (+ self.hp amount))
    nil)
  (lambda class.damage [self amount]
    (set self.hp (- self.hp amount))
    (if (self:dead?)
        :death
        :survival))
  (lambda class.give-item [self item]
    (self.inventory:add item)
    nil)
  (lambda class.remove-item [self item]
    (self.inventory:remove item)
    nil)
  class)
