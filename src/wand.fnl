(let [Wand {}]
  (lambda Wand.new [class]
    (setmetatable {:kind :wand} {:__index class
                      :__tostring (lambda [self] "Wand")}))
  Wand)
