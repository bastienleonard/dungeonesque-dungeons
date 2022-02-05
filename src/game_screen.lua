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

local Animations = require('animations')
local BaseScreen = require('base_screen')
local Camera = require('camera')
local class = require('class')
local debug_view = require('debug_view')
local GameEventHandler = require('game_event_handler')
local EventHandlersStack = require('event_handlers_stack')
local information_view = require('information_view')
local game_logic = require('game_logic')
local inventory_view = require('inventory_view')
local rendering = require('rendering')
local Unit = require('unit')
local utils = require('utils')
local Vec2 = require('vec2')

local ANIMATION_ID_CAMERA = 'camera'

local function zoom_by(self, level)
    assert(level)
    local start_scale = globals.camera._scale
    local end_scale = globals.camera._scale_after_animation
        * 2 ^ level

    if Camera.is_scale_valid(end_scale) then
        globals.camera:set_scale_after_animation(end_scale)
        self.animations:animate(
            ANIMATION_ID_CAMERA,
            start_scale,
            end_scale,
            0.2,
            function(value)
                globals.camera:set_scale(value)
                globals.camera:center_on_map_position(globals.hero.position)
            end,
            {
                on_animation_end = function()
                    assert(utils.is_power_of_two(globals.camera._scale))
                end
            }
        )
    end
end

local function draw_map(map, camera, tileset)
    love.graphics.applyTransform(camera:get_transform())
    local tile_width = tileset.tile_width
    local tile_height = tileset.tile_height
    local start_x = math.max(
        0,
        math.floor(camera.x / (tile_width * camera._scale))
    )
    local start_y = math.max(
        0,
        math.floor(camera.y / (tile_height * camera._scale))
    )
    local end_x = math.min(
        map.width - 1,
        math.ceil(love.graphics.getWidth() / (tile_width * camera._scale))
        + math.floor(camera.x / (tile_width * camera._scale))
    )
    local end_y = math.min(
        map.height - 1,
        math.ceil(love.graphics.getHeight() / (tile_height * camera._scale))
        + math.floor(camera.y / (tile_height * camera._scale))
    )

    if start_x <= end_x and start_y <= end_y then
        for x = start_x, end_x do
            for y = start_y, end_y do
                local tile = map:get_tile_or_nil(x, y)

                if tile then
                    rendering.draw_tile(x, y, tile)
                end
            end
        end
    end
end

return class(
    'GameScreen',
    {
        _extends = BaseScreen,

        _init = function(self)
            self.event_handlers = EventHandlersStack.new()
            self.event_handlers:push(GameEventHandler.new())
            globals.camera = Camera.new()
            globals.hero = Unit.new_hero()
            game_logic.enter_new_level(globals.hero)
            self.animations = Animations.new()
        end,

        update = function(self, dt)
            self.animations:update(dt)
            local camera = globals.camera
            local directions = {
                a = Vec2.LEFT,
                d = Vec2.RIGHT,
                w = Vec2.UP,
                s = Vec2.DOWN
            }

            for key, direction in pairs(directions) do
                if love.keyboard.isDown(key) then
                    camera:move_by(direction * dt * 1000)
                end
            end
        end,

        draw = function(self)
            draw_map(globals.map, globals.camera, globals.tileset)
            local handler = self.event_handlers:current()
            handler:draw()
            self.animations:draw()
            love.graphics.origin()
            information_view.draw()
            inventory_view.draw()

            if globals.DEBUG then
                debug_view.draw()
            end
        end,

        on_key_pressed = function(self, key, scancode, is_repeat)
            if key == '=' then
                zoom_by(self, 1)
            elseif key == '-' then
                zoom_by(self, -1)
            else
                self.event_handlers:current():on_key_pressed(
                    key,
                    scancode,
                    is_repeat
                )
            end
        end,

        on_mouse_wheel_moved = function(self, x, y)
            zoom_by(self, y)
        end,

        on_window_resized = function(self, width, height)
            globals.camera:center_on_map_position(globals.hero.position)
        end
    }
)
