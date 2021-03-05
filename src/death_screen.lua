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

local BaseScreen = require('base_screen')
local class = require('class')
local colors = require('colors')
local fonts = require('fonts')
local ui_scaled = require('ui_scaled')

return class(
    'DeathScreen',
    {
        _extends = BaseScreen,

        draw = function(self)
            local font = fonts.get(ui_scaled(48))
            local text = 'You died'
            local x = math.floor(
                (love.graphics.getWidth() - font:getWidth(text)) / 2
            )
            local y = math.floor(
                (love.graphics.getHeight() - font:getHeight()) / 2
            )
            love.graphics.setColor(unpack(colors.WHITE))
            love.graphics.print(
                text,
                font,
                x,
                y
            )
        end
    }
)
