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

local class = require('class')
local utils = require('utils')

local MIN_SCALE = 1
local MAX_SCALE = 16

local function is_scale_in_range(scale)
    assert(scale)
    return scale >= MIN_SCALE and scale <= MAX_SCALE
end

return class(
    'Camera',
    {
        _class_scope = function(scope)
            function scope.is_scale_valid(scale)
                assert(scale)
                return is_scale_in_range(scale) and utils.is_power_of_two(scale)
            end
        end,

        _init = function(self)
            self.x = 0
            self.y = 0
            self._scale = 4
            self._scale_after_animation = self._scale
        end,

        get_transform = function(self)
            return love.math.newTransform()
                :translate(-self.x, -self.y)
                :scale(self._scale)
        end,

        move_by = function(self, vector)
            assert(vector)
            self.x = self.x + vector.x
            self.y = self.y + vector.y
        end,

        scale_by = function(self, factor)
            assert(factor)
            self:set_scale(self._scale * factor)
        end,

        set_scale = function(self, value)
            if is_scale_in_range(value) then
                self._scale = value
            end
        end,

        set_scale_after_animation = function(self, value)
            if self.class.is_scale_valid(value) then
                self._scale_after_animation = value
            else
                error(string.format('Invalid scale %s', value))
            end
        end,

        center = function(self, x, y)
            assert(x)

            if not y then
                local position = x
                x = position.x
                y = position.y
                assert(y)
            end

            self.x = utils.round(x - love.graphics.getWidth() / 2)
            self.y = utils.round(y - love.graphics.getHeight() / 2)
        end,

        center_on_map_position = function(self, position)
            assert(position)
            self:center(
                (position.x + 0.5) * globals.tileset.tile_width * self._scale,
                (position.y + 0.5) * globals.tileset.tile_height * self._scale
            )
        end
    }
)
