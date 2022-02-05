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

function class.new()
    local instance = {
        _handlers = {}
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('EventHandlersStack')
    }
    return setmetatable(instance, metatable)
end

function class:current()
    return self._handlers[#self._handlers]
end

function class:push(handler)
    assert(handler)
    table.insert(self._handlers, handler)
end

function class:pop()
    if #self._handlers > 1 then
        table.remove(self._handlers, #self._handlers)
    else
        error('No event handler to pop')
    end
end

return class
