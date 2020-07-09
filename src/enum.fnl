(lambda enum [...]
  (let [the-enum {}]
    (each [i name (ipairs [...])]
      (tset the-enum name
            (setmetatable {} {:__tostring (lambda [self] name)})))
    the-enum))
