(lambda love.errorhandler [message]
  (print message)
  nil)

(require :utils-test)

(love.event.quit)
nil
