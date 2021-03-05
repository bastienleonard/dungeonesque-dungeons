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

local table_utils = require('table_utils')
local Vec2 = require('vec2')

local module = {}

local ICONS = {
    cursor_target = { 22, 14 },
    hero = { 27, 0 },
    enemy = { 28, 0 },
    arrows = { 42, 6 },
    potion = { 32, 13 },
    fire_wand = { 33, 5 },
    death_wand = { 34, 5 },
    ice_wand = { 35, 4 },
    nothing = { 16, 0 },
    wall = { 0, 13 },
    stairs = { 3, 6 },
    bookshelf = { 3, 7 },
    bookshelf_with_skull = { 4, 7 }
}

function module.load_tileset()
    return {
        image = love.graphics.newImage(
            'assets/tileset/monochrome-transparent_packed.png'
        ),
        tile_width = 16,
        tile_height = 16,
        icons = table_utils.map_values(
            function(key, value)
                return Vec2.new(value[1], value[2])
            end,
            ICONS
        )
    }
end

return module
