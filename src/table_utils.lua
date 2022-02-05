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

local module = {}

function module.keys(t)
    assert(t)
    local result = {}

    for key, _ in pairs(t) do
        table.insert(result, key)
    end

    return result
end

function module.dup(t)
    local result = {}

    for key, value in pairs(t) do
        result[key] = value
    end

    return result
end

function module.map_values(f, t)
    assert(f)
    assert(t)
    local result = {}

    for key, value in pairs(t) do
        result[key] = f(key, value)
    end

    return result
end

function module.remove_by_key(t, key)
    assert(t)
    assert(key ~= nil)
    local result = t[key]
    t[key] = nil
    return result
end

return module
