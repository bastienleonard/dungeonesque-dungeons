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
local FovStatus = require('fov_status')
local Item = require('item')
local table_utils = require('table_utils')
local Tile = require('tile')
local Vec2 = require('vec2')

local module = {}

-- FIXME: return quad
local function tile_rendering_metadata(tile)
    assert(tile)
    local name = nil
    local color = nil

    if tile.unit and tile.fov_status == FovStatus.IN_SIGHT then
        local unit = tile.unit

        if unit.is_hero then
            name = 'hero'
            color = colors.BLUE
        else
            name = 'enemy'
            color = colors.RED
        end
    elseif tile.item then
        local item = tile.item
        name = module.icon_name_for_item(item)
        color = module.color_for_item(item)
    elseif tile.kind == Tile.Kind.NOTHING then
        name = 'nothing'
        color = colors.DARK_GRAY
    elseif tile.kind == Tile.Kind.WALL then
        name = 'wall'
        color = colors.LIGHT_GRAY
    elseif tile.kind == Tile.Kind.STAIRS then
        name = 'stairs'
        color = colors.WHITE
    elseif tile.kind == Tile.Kind.BOOKSHELF then
        name = 'bookshelf'
        color = colors.BROWN
    elseif tile.kind == Tile.Kind.BOOKSHELF_WITH_SKULL then
        name = 'bookshelf_with_skull'
        color = colors.BROWN
    end

    assert(
        name and globals.tileset.icons[name],
        string.format('Unknown icon for tile %s', tile)
    )
    assert(color, string.format('Unknown color for tile %s', tile))
    return globals.tileset.icons[name].x, globals.tileset.icons[name].y, color
end

-- FIXME: return quad
function module.icon_name_for_item(item)
    assert(item)
    local name

    if item.kind == Item.Kind.ARROWS then
        name = 'arrows'
    elseif item.kind == Item.Kind.POTION then
        name = 'potion'
    elseif item.kind == Item.Kind.FIRE_WAND then
        name = 'fire_wand'
    elseif item.kind == Item.Kind.DEATH_WAND then
        name = 'death_wand'
    elseif item.kind == Item.Kind.ICE_WAND then
        name = 'ice_wand'
    end

    assert(name, string.format('Unknown icon for item %s', item))
    return name
end

function module.color_for_item(item)
    assert(item)
    local color

    if item.kind == Item.Kind.ARROWS then
        color = colors.BROWN
    elseif item.kind == Item.Kind.POTION then
        color = colors.RED
    elseif item.kind == Item.Kind.FIRE_WAND then
        color = colors.ORANGE
    elseif item.kind == Item.Kind.DEATH_WAND then
        color = colors.YELLOW
    elseif item.kind == Item.Kind.ICE_WAND then
        color = colors.BLUE
    end

    assert(color, string.format('Unknown color for item %s', item))
    return color
end

function module.draw_tile(x, y, tile)
    assert(x)
    assert(y)
    assert(tile)

    if globals.FOV_ENABLED and tile.fov_status == FovStatus.UNEXPLORED then
        return
    end

    local tileset_x, tileset_y, color = tile_rendering_metadata(tile)
    local alpha

    if tile.fov_status == FovStatus.IN_SIGHT then
        alpha = 1
    elseif tile.fov_status == FovStatus.EXPLORED then
        alpha = 0.3
    end

    assert(alpha)
    module.draw_at_map_position(
        Vec2.new(x, y),
        tileset_x,
        tileset_y,
        color,
        alpha
    )
end

function module.draw_at_map_position(
        position,
        tileset_x,
        tileset_y,
        color,
        alpha
)
    assert(position)
    assert(tileset_x)
    assert(tileset_y)
    local tileset = globals.tileset
    color = color or { 1, 1, 1 }
    alpha = alpha or 1
    -- FIXME: cache quad
    local quad = love.graphics.newQuad(
        tileset_x * tileset.tile_width,
        tileset_y * tileset.tile_height,
        tileset.tile_width,
        tileset.tile_height,
        tileset.image:getWidth(),
        tileset.image:getHeight()
    )
    color = table_utils.dup(color)
    table.insert(color, alpha)
    love.graphics.setColor(unpack(color))
    love.graphics.draw(
        tileset.image,
        quad,
        position.x * tileset.tile_width,
        position.y * tileset.tile_height
    )
end

return module
