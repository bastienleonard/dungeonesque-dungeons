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

local array_utils = require('array_utils')
local class = require('class')
local PaddingOrMargin = require('ui.padding_or_margin')
local table_utils = require('table_utils')

local DRAW_BOUNDS = false

local function make_padding(padding)
    if not padding then
        padding = 0
    end

    if type(padding) == 'number' then
        padding = PaddingOrMargin.new(
            padding,
            padding,
            padding,
            padding
        )
    elseif type(padding) == 'table' then
        if array_utils.is_array(padding) then
            if #padding == 0 then
                padding = { 0, 0, 0, 0 }
            end

            assert(#padding == 4)
            padding = PaddingOrMargin.new(
                padding[1],
                padding[2],
                padding[3],
                padding[4]
            )
        else
            padding = PaddingOrMargin.new(
                padding.left or 0,
                padding.right or 0,
                padding.top or 0,
                padding.bottom or 0
            )
        end
    end

    return padding
end

return class(
    'BaseWidget',
    {
        _init = function(self, options)
            assert(options)
            self.background_color = table_utils.remove_by_key(
                options,
                'background_color'
            )
            self.border = table_utils.remove_by_key(options, 'border')

            if self.border and not self.border.width then
                self.border.width = 1
            end

            self.padding = make_padding(
                table_utils.remove_by_key(options, 'padding')
            )
            self.layout = table_utils.remove_by_key(options, 'layout') or {}

            for key, _ in pairs(options) do
                error(string.format('Unknown option %s', key))
            end
        end,

        set_measured = function(self, width, height)
            self._measured_width = width
            self._measured_height = height
        end,

        is_measured = function(self)
            return self._measured_width ~= nil
                and self._measured_height ~= nil
        end,

        width = function(self)
            assert(self:is_measured())
            return self._measured_width
        end,

        height = function(self)
            assert(self:is_measured())
            return self._measured_height
        end,

        has_padding = function(self)
            return not (self.padding.left == 0
                        and self.padding.right == 0
                        and self.padding.top == 0
                        and self.padding.bottom == 0)
        end,

        draw = function(self, x, y)
            assert(x)
            assert(y)
            assert(self:is_measured())

            if self.background_color then
                love.graphics.setColor(unpack(self.background_color))
                love.graphics.rectangle(
                    'fill',
                    x,
                    y,
                    self:width(),
                    self:height()
                )
            end

            if self.border then
                love.graphics.setColor(unpack(self.border.color))
                love.graphics.rectangle(
                    'line',
                    x,
                    y,
                    self:width(),
                    self:height()
                )
            end

            if DRAW_BOUNDS then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle(
                    'line',
                    x,
                    y,
                    self:width(),
                    self:height()
                )

                if self:has_padding() then
                    love.graphics.setColor(0, 1, 1)
                    love.graphics.rectangle(
                        'line',
                        x + self.padding.left,
                        y + self.padding.top,
                        self:width() - self.padding.left - self.padding.right,
                        self:height() - self.padding.top - self.padding.bottom
                    )
                end
            end
        end
    }
)
