(local utils (require :utils))

(let [EventHandlers {}]
  (lambda EventHandlers.new [class]
    (setmetatable {:%handlers []} {:__index class}))

  (lambda EventHandlers.current [self]
    (when (= (length self.%handlers) 0)
      (error "No event handler registered"))
    (utils.array-last self.%handlers))

  (lambda EventHandlers.push [self handler]
    (table.insert self.%handlers handler)
    nil)

  (lambda EventHandlers.pop [self]
    (let [handlers-length (length self.%handlers)]
      (when (= handlers-length 0)
        (error "Can't pop event handler with no handlers registered"))
      (table.remove self.%handlers handlers-length))

    nil)

  EventHandlers)
