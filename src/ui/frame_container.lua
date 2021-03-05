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
local table_utils = require('table_utils')

return class(
    'FrameContainer',
    {
        _extends = BaseWidget,

        _init = function(self, options)
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

                if child:width() > width then
                    width = child:width()
                end

                if child:height() > height then
                    height = child:height()
                end

                self:set_measured(
                    width + self.padding.left + self.padding.right,
                    height + self.padding.top + self.padding.bottom
                )
            end
        end,

        draw = function(self, x, y)
            self.class.parent.draw(self, x, y)

            for i, child in ipairs(self.children) do
                local child_x
                local child_y

                if child.layout.align_right then
                    child_x = x + self:width() - child:width()
                else
                    child_x = x + self.padding.left
                end

                if child.layout.align_bottom then
                    child_y = y + self:height() - child:height()
                else
                    child_y = y + self.padding.top
                end

                child:draw(child_x, child_y)
            end
        end
    }
)
