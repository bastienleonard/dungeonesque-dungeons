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

local ItemKind = require('item_kind')
local utils = require('utils')

local class = {}
class.Kind = ItemKind

function class.new_from_kind(item_kind)
    assert(item_kind)
    local item

    if item_kind == class.Kind.ARROWS then
        item = class.new_arrows()
    elseif item_kind == class.Kind.POTION then
        item = class.new_potion()
    elseif item_kind == class.Kind.FIRE_WAND then
        item = class.new_fire_wand()
    elseif item_kind == class.Kind.DEATH_WAND then
        item = class.new_death_wand()
    elseif item_kind == class.Kind.ICE_WAND then
        item = class.new_ice_wand()
    end

    assert(item)
    return item
end

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

function class.new_potion()
    local instance = {
        kind = class.Kind.POTION,
        quantity = 1
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Potion', 'quantity')
    }
    return setmetatable(instance, metatable)
end

function class.new_fire_wand()
    local instance = {
        kind = class.Kind.FIRE_WAND,
        quantity = 1
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('FireWand', 'quantity')
    }
    return setmetatable(instance, metatable)
end

function class.new_death_wand()
    local instance = {
        kind = class.Kind.DEATH_WAND,
        quantity = 1
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('DeathWand', 'quantity')
    }
    return setmetatable(instance, metatable)
end

function class.new_ice_wand()
    local instance = {
        kind = class.Kind.ICE_WAND,
        quantity = 1
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('IceWand', 'quantity')
    }
    return setmetatable(instance, metatable)
end

return class
