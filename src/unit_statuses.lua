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

function class.new()
    local instance = {
        _statuses = {}
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('UnitStatuses')
    }
    return setmetatable(instance, metatable)
end

function class:on_turn_elapsed()
    for status, turns in pairs(self._statuses) do
        if turns > 0 then
            self._statuses[status] = self._statuses[status] - 1
        end
    end
end

function class:has(status)
    local turns = self._statuses[status]
    return turns and turns > 0
end

function class:add(status, turns)
    assert(status)
    assert(turns)

    if not self._statuses[status] then
        self._statuses[status] = 0
    end

    self._statuses[status] = self._statuses[status] + turns
end

return class
