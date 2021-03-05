local utils = require('./utils')

local class = {}

function class.new(max_hp)
    local instance = {
        max_hp = max_hp,
        current_hp = max_hp
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Health', 'current_hp', 'max_hp')
    }
    return setmetatable(instance, metatable)
end

function class:is_dead()
    return self.current_hp <= 0
end

function class:dec()
    self.current_hp = math.max(0, self.current_hp - 1)
end

return class
