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

local BaseWidget = require('ui.base_widget')
local class = require('class')
local colors = require('colors')
local table_utils = require('table_utils')
local ui_scaled = require('ui_scaled')

local function dt_to_y(self, dt)
    return self:height() - 1 - self.padding.bottom - dt * 3000
end

return class(
    'FramesChartView',
    {
        _extends = BaseWidget,

        _init = function(self, options)
            self.get_dts = table_utils.remove_by_key(options, 'get_dts')
            assert(self.get_dts)
            options.background_color = colors.DARK_BLUE
            options.border = {
                color = colors.RED,
                width = 1
            }
            options.padding = options.border.width
            self.class.parent._init(self, options)
        end,

        measure = function(self)
            self:set_measured(ui_scaled(400), ui_scaled(200))
        end,

        draw = function(self, x, y)
            self.class.parent.draw(self, x, y)
            x = x + self.padding.left
            y = y + self.padding.top
            local self_x = x
            local self_y = y
            local dts = self.get_dts()
            local max_dts = self:width()
                - self.padding.left
                - self.padding.right

            while #dts > max_dts do
                -- TODO: optimize, use a ring buffer
                table.remove(dts, 1)
            end

            love.graphics.setColor(unpack(colors.LIGHT_PEACH))

            for _, dt in ipairs(dts) do
                love.graphics.line(
                    x,
                    y + dt_to_y(self, 0),
                    x,
                    y + dt_to_y(self, dt)
                )
                x = x + 1
            end

            love.graphics.setColor(unpack(colors.RED))
            love.graphics.line(
                self_x,
                self_y + dt_to_y(self, 1 / 60),
                self_x + self:width() - 1,
                self_y + dt_to_y(self, 1 / 60)
            )
        end
    }
)
