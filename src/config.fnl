(let [class {}]
  (lambda class.new [dev-mode]
    (setmetatable {:dev-mode dev-mode} {:__index class}))
  class)
