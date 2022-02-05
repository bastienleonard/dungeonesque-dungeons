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
local utils = require('utils')
local Vec2 = require('vec2')

-- The room will extend 1 past x + width and y + height
return class(
    'Room',
    {
        _props = { 'x', 'y', 'width', 'height' },

        _init = function(self, x, y, width, height)
            assert(x)
            assert(y)
            assert(width)
            assert(height)
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        end,

        right = function(self)
            return self.x + self.width
        end,

        bottom = function(self)
            return self.y + self.height
        end,

        center = function(self)
            return Vec2.new(
                math.floor(self.x + self.width / 2),
                math.floor(self.y + self.height / 2)
            )
        end,

        all_coords = function(self, padding)
            padding = padding or 0
            local result = {}

            for x = self.x - padding, self.x + self.width + padding do
                for y = self.y - padding, self.y + self.height + padding do
                    table.insert(result, { x, y })
                end
            end

            return result
        end
    }
)
