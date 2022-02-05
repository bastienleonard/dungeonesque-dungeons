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

local utils = require('utils')

local class = {}

function class.new(max_hp)
    local instance = {
        max_hp = max_hp,
        current_hp = max_hp
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Health', 'current_hp', 'max_hp')
    }
    return setmetatable(instance, metatable)
end

function class:is_dead()
    return self.current_hp <= 0
end

function class:is_full()
    return self.current_hp == self.max_hp
end

function class:dec(amount)
    amount = amount or 1
    self.current_hp = math.max(0, self.current_hp - amount)
end

function class:inc(amount)
    amount = amount or 1
    self.current_hp = math.min(
        self.max_hp,
        self.current_hp + amount
    )
end

return class
