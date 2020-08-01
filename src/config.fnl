(let [class {}]
  (lambda class.new [options]
    (let [dev-mode? (. options :dev-mode?)
          fov-enabled? (. options :fov-enabled?)]
      (assert (not= dev-mode? nil))
      (assert (not= fov-enabled? nil))
      (setmetatable {:dev-mode? dev-mode?
                     :fov-enabled? fov-enabled?}
                    {:__index class})))
  class)
