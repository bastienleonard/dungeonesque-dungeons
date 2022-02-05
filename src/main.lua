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

local colors = require('colors')
local error_handler = require('error_handler')
local FramesChartView = require('frames_chart_view')
local game_logic = require('game_logic')
local GameScreen = require('game_screen')
local random = require('random')
local Screens = require('screens')
local utils = require('utils')

globals = {}
local dts = {}

local function draw_frame_times(dts)
    local frames_chart_view = FramesChartView.new({
            get_dts = function() return dts end
    })
    local root = frames_chart_view
    root:measure()
    root:draw(
        love.graphics.getWidth() - root:width(),
        love.graphics.getHeight() - root:height()
    )
end

function globals.push_event_handler(handler)
    local current_screen = globals.screens:current()
    local event_handlers = current_screen.event_handlers
    event_handlers:push(handler)
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
    globals.DEBUG = true
    globals.INVINCIBILITY_ENABLED = false
    globals.FOV_ENABLED = true
    globals.ARROWS_ENABLED = false
    globals.tileset = require('tileset').load_tileset()
    globals.level_counter = 0
    globals.screens = Screens.new()
    globals.screens:push(GameScreen.new())
    love.graphics.setColor(unpack(colors.WHITE))
    love.graphics.setBackgroundColor(unpack(colors.BLACK))
end

function love.update(dt)
    table.insert(dts, dt)
    globals.screens:current():update(dt)
end

function love.draw()
    globals.screens:current():draw()

    if globals.DEBUG then
        love.graphics.origin()
        draw_frame_times(dts)
    end
end

function love.keypressed(key, scancode, is_repeat)
    if key == 'return' and love.keyboard.isDown('lalt', 'ralt') then
        love.window.setFullscreen(not love.window.getFullscreen())
    else
        globals.screens:current():on_key_pressed(key, scancode, is_repeat)
    end
end

function love.wheelmoved(x, y)
    globals.screens:current():on_mouse_wheel_moved(x, y)
end

function love.resize(width, height)
    globals.screens:current():on_window_resized(width, height)
end

function love.errorhandler(message)
    return error_handler.handle(message)
end
