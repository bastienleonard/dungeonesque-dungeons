(lambda love.errorhandler [message]
  (print message)
  nil)

(let [files (love.filesystem.getDirectoryItems "")]
  (each [i file (ipairs files)]
    (let [module (file:match "(%g*-test).lua")]
      (when module
        (print (: "Running module %s" :format module))
        (require module)))))

(print "Done")
(love.event.quit)
nil
