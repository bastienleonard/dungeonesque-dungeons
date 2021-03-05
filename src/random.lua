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

function module.choice(array)
    assert(array)

    if #array == 0 then
        error("Can't pick random item from empty array")
    end

    local index = love.math.random(1, #array)
    return array[index]
end

function module.shuffle(array)
    assert(array)

    if #array > 1 then
        for i = 1, #array - 1 do
            local index = love.math.random(i, #array)
            array[i], array[index] = array[index], array[i]
        end
    end
end

function module.shuffled(array)
    assert(array)
    array = table_utils.dup(array)
    module.shuffle(array)
    return array
end

return module
