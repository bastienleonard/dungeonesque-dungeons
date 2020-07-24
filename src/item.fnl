(lambda item->string [self]
  (: "Item kind=%s uses=%s"
     :format
     self.kind
     self.uses))

(let [class {}]
  (lambda class.new [kind uses]
    (setmetatable {:kind kind
                   :uses uses}
                  {:__index class
                   :__tostring item->string}))
  (lambda class.zero-uses? [self]
    (= self.uses 0))
  (lambda class.inc-uses [self]
    (set self.uses (+ self.uses 1))
    nil)
  (lambda class.dec-uses [self]
    (set self.uses (- self.uses 1))
    nil)
  class)
