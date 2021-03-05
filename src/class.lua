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

return function(name, options)
    assert(name)
    assert(options)
    assert(not options.new)
    local class = options

    if class._extends then
        setmetatable(class, { __index = class._extends })
        class.parent = class._extends
    end

    if class._class_scope then
        class._class_scope(class)
    end

    class._props = class._props or {}
    class._init = class._init or function() end
    options.new = function(...)
        local instance = {}
        instance.class = class
        class._init(instance, ... )
        local metatable = {
            __index = class,
            __tostring = utils.make_to_string(
                name,
                unpack(class._props)
            )
        }
        return setmetatable(instance, metatable)
    end
    return class
end
