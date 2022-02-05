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
local enum = require('enum')
local table_utils = require('table_utils')

local function vertical(self)
    return self.orientation == self.class.Orientation.VERTICAL
end

local function horizontal(self)
    return self.orientation == self.class.Orientation.HORIZONTAL
end

return class(
    'StackContainer',
    {
        _extends = BaseWidget,

        _class_scope = function(scope)
            scope.Orientation = enum('HORIZONTAL', 'VERTICAL')
        end,

        _init = function(self, options)
            self.orientation = table_utils.remove_by_key(
                options,
                'orientation'
            )
            assert(self.orientation)
            self.children = table_utils.remove_by_key(options, 'children')
            assert(self.children)
            self.class.parent._init(self, options)
        end,

        measure = function(self)
            local width = 0
            local height = 0

            for _, child in ipairs(self.children) do
                -- FIXME: make sure this is safe
                assert(not child:is_measured())
                child:measure()

                if vertical(self) then
                    if child:width() > width then
                        width = child:width()
                    end

                    height = height + child:height()
                elseif horizontal(self) then
                    width = width + child:width()

                    if child:height() > height then
                        height = child:height()
                    end
                else
                    -- FIXME
                    error('TODO')
                end
            end

            self:set_measured(
                width + self.padding.left + self.padding.right,
                height + self.padding.top + self.padding.bottom
            )
        end,

        draw = function(self, x, y)
            self.class.parent.draw(self, x, y)

            for _, child in ipairs(self.children) do
                if child.layout.center_horizontally then
                    assert(vertical(self))
                    child:draw(
                        x + (self:width() - child:width()) / 2,
                        y + self.padding.top
                    )
                else
                    child:draw(x + self.padding.left, y + self.padding.top)
                end

                if vertical(self) then
                    y = y + child:height()
                elseif horizontal(self) then
                    x = x + child:width()
                else
                    -- FIXME
                    error('TODO')
                end
            end
        end
    }
)
