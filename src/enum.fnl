(lambda enum [...]
  (let [the-enum {}
        all []]
    (each [i name (ipairs [...])]
      (when (= name :ALL)
        (error "ALL is a reserved name"))

      (let [value (setmetatable {} {:__index the-enum
                              :__tostring (lambda [self] name)})]
        (tset the-enum
              name
              value)
        (table.insert all value)))
    (set the-enum.ALL all)
    the-enum))
