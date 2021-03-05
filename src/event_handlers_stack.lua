local utils = require('./utils')

local class = {}

function class.new()
    local instance = {
        _handlers = {}
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('EventHandlersStack')
    }
    return setmetatable(instance, metatable)
end

function class:current()
    return self._handlers[#self._handlers]
end

function class:push(handler)
    assert(handler)
    table.insert(self._handlers, handler)
end

function class:pop()
    if #self._handlers > 1 then
        table.remove(self._handlers, #self._handlers)
    else
        error('No event handler to pop')
    end
end

return class
