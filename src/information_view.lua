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

local class = require('class')
local fonts = require('fonts')
local FovStatus = require('fov_status')
local inventory_view = require('inventory_view')
local StackContainer = require('ui.stack_container')
local TextWidget = require('ui.text_widget')
local Tile = require('tile')
local ui_scaled = require('ui_scaled')
local UnitStatus = require('unit_status')

local module = {}

local function make_status_name(status)
    assert(status)

    if status == UnitStatus.FROZEN then
        return 'Frozen'
    end

    error(string.format('Unhandled status %s', status))
end

local function make_tile_info_text()
    local map = globals.map
    local camera = globals.camera
    local tileset = globals.tileset
    local x, y = love.mouse.getPosition()
    x, y = camera:get_transform():inverseTransformPoint(x, y)
    x = math.floor(x / tileset.tile_width)
    y = math.floor(y / tileset.tile_height)
    local tile = map:get_tile_or_nil(x, y)

    if not tile or tile.fov_status == FovStatus.UNEXPLORED then
        return {}
    end

    local result = {}

    if tile.kind == Tile.Kind.STAIRS then
        table.insert(result, 'Stairs')
    elseif tile.kind == Tile.Kind.BOOKSHELF
        or tile.kind == Tile.Kind.BOOKSHELF_WITH_SKULL then
        table.insert(result, 'Bookshelf')
    elseif tile.kind == Tile.Kind.WALL then
        table.insert(result, 'Wall')
    end

    if tile.unit
        and tile.fov_status == FovStatus.IN_SIGHT
        and not tile.unit:is_hero() then
        local unit = tile.unit
        local statuses = ''

        for status, turns in pairs(unit.statuses._statuses) do
            local text = string.format(
                ' %s for %s turns',
                make_status_name(status),
                turns
            )
            statuses = statuses .. text
        end

        table.insert(
            result,
            string.format(
                'Enemy HP: %s/%s%s',
                unit.health.current_hp,
                unit.health.max_hp,
                statuses
            )
        )
    end

    if tile.item then
        local item = tile.item
        table.insert(
            result,
            inventory_view.make_item_name(item)
        )
    end

    return result
end

function module.draw()
    local font = fonts.get(ui_scaled(40))
    local hero = globals.hero
    local children = {
        TextWidget.new({
                text = string.format(
                    'HP: %s/%s',
                    hero.health.current_hp,
                    hero.health.max_hp
                ),
                font = font
        })
    }

    for _, text in ipairs(make_tile_info_text()) do
        table.insert(children, TextWidget.new({ text = text, font = font }))
    end

    local column = StackContainer.new({
            orientation = StackContainer.Orientation.VERTICAL,
            children = children,
            padding = ui_scaled(8)
    })
    local root = column
    root:measure()
    root:draw(0, 0)
end

return module
