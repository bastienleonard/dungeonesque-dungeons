local ItemKind = require('./item_kind')
local utils = require('./utils')

local class = {}
class.Kind = ItemKind

function class.new_arrows()
    local instance = {
        kind = class.Kind.ARROWS,
        quantity = 1
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Arrows', 'quantity')
    }
    return setmetatable(instance, metatable)
end

return class
