(local utils (require :utils))

(let [class {}]
  (lambda class.new [initial-screen]
    (setmetatable {:%screens [initial-screen]} {:__index class}))
  (lambda class.current [self]
    (when (= (length self.%screens) 0)
      (error "No screens"))
    (utils.array-last self.%screens))
  (lambda class.replace-current [self screen]
    (tset self.%screens
          (length self.%screens)
          screen)
    nil)
  class)
