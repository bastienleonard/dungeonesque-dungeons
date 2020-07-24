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
  (lambda class.heal [self amount]
    (set self.hp (+ self.hp amount))
    nil)
  class)
