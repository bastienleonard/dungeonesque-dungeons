local Item = require('./item')
local utils = require('./utils')

local class = {}

function class.new()
    local instance = {
        items = {}
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Inventory')
    }
    return setmetatable(instance, metatable)
end

function class:add(item)
    assert(item)
    local existing_item = nil

    for _, current in ipairs(self.items) do
        if current.kind == item.kind then
            existing_item = current
            break
        end
    end

    if existing_item == nil then
        table.insert(self.items, item)
    else
        existing_item.quantity = existing_item.quantity + item.quantity
    end
end

function class:decrease_quantity(index)
    assert(index)
    assert(type(index) == 'number')
    local item = self.items[index]

    if not item then
        return
    end

    item.quantity = item.quantity - 1
    assert(item.quantity >= 0)

    if item.quantity == 0 then
        assert(table.remove(self.items, index) ~= nil)
    end
end

return class
