local Health = require('./health')
local Inventory = require('./inventory')
local utils = require('./utils')

local class = {}

local function new_unit(options)
    local is_hero = utils.require_not_nil(options.is_hero, 'is_hero')
    local max_hp = utils.require_not_nil(options.max_hp, 'max_hp')
    local position = options.position
    local instance = {
        position = position,
        is_hero = is_hero,
        health = Health.new(max_hp),
        inventory = Inventory.new()
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string(
            'Unit',
            'is_hero',
            'position',
            'health'
        )
    }
    return setmetatable(instance, metatable)
end

function class.new_hero()
    return new_unit({
            is_hero = true,
            max_hp = 10
    })
end

function class.new_enemy(position)
    assert(position)
    local enemy = new_unit({
            is_hero = false,
            max_hp = 3,
            position = position
    })
    return enemy
end

return class
