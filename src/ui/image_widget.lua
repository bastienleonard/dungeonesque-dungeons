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

local BaseWidget = require('ui.base_widget')
local class = require('class')
local colors = require('colors')
local table_utils = require('table_utils')

return class(
    'ImageWidget',
    {
        _extends = BaseWidget,

        _init = function(self, options)
            self._texture = table_utils.remove_by_key(options, 'texture')
            assert(self._texture)
            self._color = table_utils.remove_by_key(options, 'color')
            assert(self._color)
            self._quad = table_utils.remove_by_key(options, 'quad')
            assert(self._quad)
            local x, y, w, h = self._quad:getViewport()
            self._scaled_width = table_utils.remove_by_key(
                options,
                'scaled_width'
            ) or w
            self._scaled_height = table_utils.remove_by_key(
                options,
                'scaled_height'
            ) or h
            self.class.parent._init(self, options)
            self._scale_x = self._scaled_width / w
            self._scale_y = self._scaled_height / h
        end,

        measure = function(self)
            self:set_measured(
                self._scaled_width + self.padding.left + self.padding.right,
                self._scaled_height + self.padding.top + self.padding.bottom
            )
        end,

        draw = function(self, x, y)
            self.class.parent.draw(self, x, y)
            love.graphics.setColor(unpack(self._color))
            love.graphics.draw(
                self._texture,
                self._quad,
                x + self.padding.left,
                y + self.padding.top,
                0,              -- orientation
                self._scale_x,
                self._scale_y
            )
        end
    }
)
