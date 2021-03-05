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

local table_utils = require('table_utils')

local module = {}

function module.is_array(x)
    if not type(x) == 'table' then
        return false
    end

    return module.all(
        table_utils.keys(x),
        function(key)
            return type(key) == 'number'
        end
    )
end

function module.last(array)
    assert(array)
    return array[#array]
end

function module.map(array, f)
    assert(array)
    assert(f)
    local result = {}

    for _, item in ipairs(array) do
        table.insert(result, f(item))
    end

    return result
end

function module.map_with_index(array, f)
    assert(array)
    assert(f)
    local result = {}

    for i, item in ipairs(array) do
        table.insert(result, f(i, item))
    end

    return result
end

function module.contains(array, value)
    for _, item in ipairs(array) do
        if item == value then
            return true
        end
    end

    return false
end

function module.index_of(array, target)
    assert(array)
    assert(target)

    for i, item in ipairs(array) do
        if item == target then
            return i
        end
    end

    error(string.format('Failed to find %s in array', target))
end

function module.sorted(array, comp)
    assert(array)
    array = table_utils.dup(array)
    table.sort(array, comp)
    return array
end

function module.remove(array, value)
    local index = nil
    local found_item = nil

    for i, item in ipairs(array) do
        if item == value then
            index = i
            found_item = item
            break
        end
    end

    assert(index, string.format('Failed to remove %s in array', value))
    table.remove(array, index)
    return found_item
end

function module.clear(array)
    assert(array)

    while #array > 0 do
        table.remove(array, #array)
    end
end

function module.sum(array)
    assert(array)
    local result = 0

    for _, item in ipairs(array) do
        result = result + item
    end

    return result
end

function module.all(array, predicate)
    assert(array)
    assert(predicate)

    for _, item in ipairs(array) do
        if not predicate(item) then
            return false
        end
    end

    return true
end

function module.none(array, predicate)
    return module.all(array, function(item) return not predicate(item) end)
end

function module.sorted(array)
    assert(array)
    array = table_utils.dup(array)
    table.sort(array)
    return array
end

return module
