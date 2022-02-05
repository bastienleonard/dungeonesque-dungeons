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

local class = require('class')

return class(
    'BaseScreen',
    {
        update = function(self, dt)
        end,

        draw = function(self)
        end,

        on_key_pressed = function(self, key, scancode, is_repeat)
        end,

        on_mouse_wheel_moved = function(self, x, y)
        end,

        on_window_resized = function(self, width, height)
        end
    }
)
