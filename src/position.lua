local class = {}

local function to_string(self)
    return string.format('(%s,%s)', self.x, self.y)
end

function class.new(x, y)
    assert(x)
    assert(y)
    local instance = {
        x = x,
        y = y
    }
    local metatable = {
        __index = class,
        __tostring = to_string
    }
    return setmetatable(instance, metatable)
end

function class:plus(other)
    assert(other)
    return class.new(self.x + other.x, self.y + other.y)
end

return class
