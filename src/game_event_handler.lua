-- Copyright 2021 Bastien Léonard

-- This file is part of Dungeonesque Dungeons.

-- Dungeonesque Dungeons is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at your
-- option) any later version.

-- Dungeonesque Dungeons is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
-- more details.

-- You should have received a copy of the GNU General Public License along with
-- Dungeonesque Dungeons. If not, see <https://www.gnu.org/licenses/>.

local BaseEventHandler = require('base_event_handler')
local game_logic = require('game_logic')
local utils = require('utils')
local Vec2 = require('vec2')

local super = BaseEventHandler
local class = setmetatable({}, { __index = super })

local function handle_direction_keys(key)
    assert(key)
    local directions = {
        left = Vec2.LEFT,
        right = Vec2.RIGHT,
        up = Vec2.UP,
        down = Vec2.DOWN
    }

    for direction, position in pairs(directions) do
        if direction == key then
            local new_position = globals.hero.position + position
            game_logic.attempt_move_unit(
                globals.hero,
                new_position,
                globals.map
            )
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
        game_logic.use_item(globals.hero, inventory_index)
        return true
    end

    return false
end

function class.new()
    local instance = {}
    super._init(instance)
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
