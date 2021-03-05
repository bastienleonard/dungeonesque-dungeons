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

local BaseEventHandler = require('base_event_handler')
local utils = require('utils')
local Vec2 = require('vec2')

local super = BaseEventHandler
local class = setmetatable({}, { __index = super })

function class._init(self, range, on_tile_selected)
    super._init(self)
    self.range = range
    self.on_tile_selected = on_tile_selected
    self.cursor_map_position = globals.hero.position
end

function class:on_key_pressed(key, scancode, is_repeat)
    if key == 'escape' then
        self:exit()
        return
    end

    if key == 'return' or key == 'space' then
        local tile = globals.map:get_tile_or_nil(self.cursor_map_position)

        if tile then
            self:on_tile_selected(tile)
        end

        return
    end

    local directions = {
        left = Vec2.new(-1, 0),
        right = Vec2.new(1, 0),
        up = Vec2.new(0, -1),
        down = Vec2.new(0, 1)
    }

    for direction, position in pairs(directions) do
        if direction == key then
            local new_position = self.cursor_map_position + position
            local distance = utils.round(
                utils.distance(globals.hero.position, new_position)
            )

            if distance <= self.range then
                self.cursor_map_position = new_position
            end

            break
        end
    end
end

function class:draw()
    local rendering = require('rendering')
    rendering.draw_at_map_position(
        self.cursor_map_position,
        globals.tileset.icons.cursor_target.x,
        globals.tileset.icons.cursor_target.y
    )
end

return class
