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
local class = require('class')

return class(
    'Screens',
    {
        _init = function(self)
            self._screens = {}
        end,

        current = function(self)
            return array_utils.last(self._screens)
        end,

        push = function(self, screen)
            assert(screen)
            table.insert(self._screens, screen)
        end,

        replace_last = function(self, screen)
            assert(screen)
            assert(#self._screens > 0)
            self._screens[#self._screens] = screen
        end
    }
)
