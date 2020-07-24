(let [class {}]
  (lambda class.new []
    (setmetatable {:%items []} {:__index class}))
  (lambda class.add [self item]
    (table.insert self.%items item)
    nil)

  ;; position is 0-based
  (lambda class.get! [self position]
    (when (or (< position 0) (>= position (self:length)))
      (error (: "Position %s is out of bounds for item with length %s"
                :format
                position
                (self:length))))

    (. self.%items (+ position 1)))

  ;; position is 0-based
  (lambda class.get-or-nil [self position]
    (if (or (< position 0) (>= position (self:length)))
        nil
        (. self.%items (+ position 1))))

  (lambda class.length [self]
    (length self.%items))
  (lambda class.items [self]
    self.%items)
  class)
