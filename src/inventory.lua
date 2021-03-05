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

local array_utils = require('array_utils')
local Item = require('item')
local utils = require('utils')

local class = {}

local ORDER = {
    Item.Kind.ARROWS,
    Item.Kind.DEATH_WAND,
    Item.Kind.FIRE_WAND,
    Item.Kind.ICE_WAND,
    Item.Kind.POTION
}

-- TODO: insert at the correct position instead of sorting the whole thing
local function reorder(self)
    table.sort(
        self.items,
        function(a, b)
            return array_utils.index_of(ORDER, a.kind)
                < array_utils.index_of(ORDER, b.kind)
        end
    )
end

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

    reorder(self)
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

    reorder(self)
end

return class
