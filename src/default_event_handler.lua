local game_logic = require('./game_logic')
local Position = require('./position')
local utils = require('./utils')

local class = {}

local function handle_direction_keys(key)
    assert(key)
    local directions = {
        left = Position.new(-1, 0),
        right = Position.new(1, 0),
        up = Position.new(0, -1),
        down = Position.new(0, 1)
    }

    for direction, position in pairs(directions) do
        if direction == key then
            local new_position = hero.position:plus(position)
            game_logic.attempt_move_unit(hero, new_position, map)
            return true
        end
    end

    return false
end

-- Keys from 1 to 9
local function handle_item_keys(key)
    assert(key)
    local inventory_index = tonumber(key)

    if inventory_index ~= nil then
        game_logic.use_item(hero, inventory_index)
        return true
    end

    return false
end

function class.new()
    local instance = {}
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('DefaultEventHandler')
    }
    return setmetatable(instance, metatable)
end

function class:on_key_pressed(key, scancode, is_repeat)
    local handled = handle_direction_keys(key)

    if not handled then
        handle_item_keys(key)
    end
end

return class
