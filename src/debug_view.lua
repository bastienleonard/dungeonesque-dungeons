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

local array_utils = require('array_utils')
local colors = require('colors')
local fonts = require('fonts')
local ui_scaled = require('ui_scaled')

local module = {}

local function get_tile_info()
    local function get_unit_info(tile)
        if not tile then
            return
        end

        local unit_info

        if tile.unit then
            local unit = tile.unit
            local kind

            if unit.is_hero then
                kind = 'hero'
            else
                kind = 'enemy'
            end

            local hp = string.format(
                '%s/%s',
                unit.health.current_hp,
                unit.health.max_hp
            )
            unit_info = string.format('Unit : %s %s', kind, hp)
        else
            unit_info = 'Unit: none'
        end

        return unit_info
    end

    local function get_item_info(tile)
        if not tile then
            return
        end

        return string.format(
            'Item: %s',
            tile.item
        )
    end

    local x, y = love.mouse.getPosition()
    x, y = globals.camera:get_transform():inverseTransformPoint(x, y)
    x = math.floor(x / globals.tileset.tile_width)
    y = math.floor(y / globals.tileset.tile_height)
    local tile = globals.map:get_tile_or_nil(x, y)
    local unit_info = get_unit_info(tile)
    local item_info = get_item_info(tile)
    return string.format(
        '(%s,%s)\n%s\n%s',
        x,
        y,
        unit_info,
        item_info
    )
end

local function get_hero_info()
    local function get_hp_info()
        return string.format(
            'HP: %s/%s',
            globals.hero.health.current_hp,
            globals.hero.health.max_hp
        )
    end

    local function get_inventory_info()
        local items = table.concat(
            array_utils.map(
                globals.hero.inventory.items,
                function(item)
                    return tostring(item)
                end
            ),
            ', '
        )
        return string.format('Inventory: %s', items)
    end

    local hp_info = get_hp_info()
    local inventory_info = get_inventory_info()
    return string.format('%s\n%s', hp_info, inventory_info)
end

local function get_level_info()
    local map = globals.map

    local function get_enemies_info()
        return string.format(
            '%s enemies left',
            #globals.enemies
        )
    end

    local level_counter = string.format('Level %s', globals.level_counter)
    local map_size = string.format('Map size: %sx%s', map.width, map.height)
    local enemies_info = get_enemies_info()
    return string.format('%s\n%s\n%s', level_counter, map_size, enemies_info)
end

local function get_misc_info()
    return string.format('Zoom level: %s', globals.camera._scale)
end

function module.draw()
    local text = string.format(
        '%s\n%s\n%s\n%s\n%s',
        string.format('%s FPS', love.timer.getFPS()),
        get_tile_info(),
        get_hero_info(),
        get_level_info(),
        get_misc_info()
    )
    love.graphics.setColor(unpack(colors.WHITE))
    love.graphics.print(
        text,
        fonts.get(ui_scaled(20)),
        love.graphics.getWidth() - ui_scaled(200),
        0
    )
end

return module
