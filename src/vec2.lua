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

local utils = require('utils')

local class = {}

local function add(self, other)
    assert(self)
    assert(other)
    return class.new(self.x + other.x, self.y + other.y)
end

local function mul(self, n)
    assert(self)
    assert(type(n) == 'number')
    return class.new(self.x * n, self.y * n)
end

function class.new(x, y)
    assert(x)
    assert(y)
    local instance = {
        x = x,
        y = y
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Vec2', 'x', 'y'),
        __add = add,
        __mul = mul
    }
    return setmetatable(instance, metatable)
end

class.LEFT = class.new(-1, 0)
class.RIGHT = class.new(1, 0)
class.UP = class.new(0, -1)
class.DOWN = class.new(0, 1)

return class
