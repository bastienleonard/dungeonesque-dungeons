(let [Wand {}]
  (lambda Wand.new [class]
    (setmetatable {} {:__index class
                      :__tostring (lambda [self] "Wand")}))
  Wand)
