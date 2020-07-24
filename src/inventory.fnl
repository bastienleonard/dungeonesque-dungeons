(let [Inventory {}]
  (lambda Inventory.new [class]
    (setmetatable {:%items []} {:__index class}))
  (lambda Inventory.add [self item]
    (table.insert self.%items item)
    nil)

  ;; position is 0-based
  (lambda Inventory.get! [self position]
    (when (or (< position 0) (>= position (self:length)))
      (error (: "Position %s is out of bounds for item with length %s"
                :format
                position
                (self:length))))

    (. self.%items (+ position 1)))

  ;; position is 0-based
  (lambda Inventory.get-or-nil [self position]
    (if (or (< position 0) (>= position (self:length)))
        nil
        (. self.%items (+ position 1))))

  (lambda Inventory.length [self]
    (length self.%items))
  (lambda Inventory.items [self]
    self.%items)
  Inventory)
