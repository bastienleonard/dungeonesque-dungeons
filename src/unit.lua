-- Copyright 2022 Bastien Léonard

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

local Health = require('health')
local Inventory = require('inventory')
local UnitStatuses = require('unit_statuses')
local utils = require('utils')

local class = {}

function class.new(options)
    local max_hp = utils.require_not_nil(options.max_hp, 'max_hp')
    local position = options.position
    local instance = {
        position = position,
        health = Health.new(max_hp),
        statuses = UnitStatuses.new(),
        inventory = Inventory.new()
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string(
            'Unit',
            'position',
            'statuses',
            'health'
        )
    }
    return setmetatable(instance, metatable)
end

function class:is_hero()
    assert(globals.hero)
    return self == globals.hero
end

return class
