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

local BaseScreen = require('base_screen')
local class = require('class')
local colors = require('colors')
local fonts = require('fonts')
local StackContainer = require('ui.stack_container')
local TextWidget = require('ui.text_widget')
local ui_scaled = require('ui_scaled')

local COLOR_DEFAULT = colors.DARK_GRAY
local COLOR_SELECTION = colors.WHITE
local BUTTONS = {
    {
        text = 'New game',
        action = function()
            local GameScreen = require('game_screen')
            globals.screens:replace_last(GameScreen.new())
        end
    },
    {
        text = 'Quit',
        action = function()
            love.event.quit()
        end
    }
}

local function move_selection(self, offset)
    assert(self)
    assert(offset)
    local new_selected_item = self.selected_item + offset

    if new_selected_item >= 1 and new_selected_item <= #BUTTONS then
        self.selected_item = new_selected_item
    end
end

local function activate_selection(self)
    BUTTONS[self.selected_item].action()
end

return class(
    'DeathScreen',
    {
        _extends = BaseScreen,

        _init = function(self)
            self.selected_item = 1
        end,

        draw = function(self)
            local function make_color(i)
                if i == self.selected_item then
                    return COLOR_SELECTION
                end

                return COLOR_DEFAULT
            end

            local font = fonts.get(ui_scaled(48))
            local children = {
                TextWidget.new({
                        text = 'You died',
                        text_color = colors.LIGHT_GRAY,
                        font = fonts.get(ui_scaled(96))
                })
            }

            for i, button in ipairs(BUTTONS) do
                table.insert(
                    children,
                    TextWidget.new({
                            text = button.text,
                            text_color = make_color(i),
                            font = font
                    })
                )
            end

            local root = StackContainer.new({
                    orientation = StackContainer.Orientation.VERTICAL,
                    children = children
            })
            root:measure()
            local x = math.floor(
                (love.graphics.getWidth() - root:width()) / 2.0
            )
            local y = math.floor(
                (love.graphics.getHeight() - root:height()) / 2.0
            )
            root:draw(x, y)
        end,

        on_key_pressed = function(self, key, scancode, is_repeat)
            if key == 'up' then
                move_selection(self, -1)
            elseif key == 'down' then
                move_selection(self, 1)
            elseif key == 'return' then
                activate_selection(self)
            end
        end
    }
)
