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
local utils = require('utils')

return class(
    'TextWidget',
    {
        _extends = BaseWidget,

        _init = function(self, options)
            self._text = table_utils.remove_by_key(options, 'text') or ''
            self._font = table_utils.remove_by_key(options, 'font')
            assert(self._font)
            self.class.parent._init(self, options)
        end,

        measure = function(self)
            self:set_measured(
                self._font:getWidth(self._text)
                + self.padding.left
                + self.padding.right,
                self._font:getHeight()
                + self.padding.top
                + self.padding.bottom
            )
        end,

        draw = function(self, x, y)
            self.class.parent.draw(self, x, y)
            love.graphics.setColor(unpack(colors.WHITE))
            utils.print_with_shadow(
                self._text,
                self._font,
                x + self.padding.left,
                y + self.padding.top
            )
        end
    }
)
