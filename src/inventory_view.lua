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

local array_utils = require('array_utils')
local colors = require('colors')
local FrameContainer = require('ui.frame_container')
local fonts = require('fonts')
local ImageWidget = require('ui.image_widget')
local Item = require('item')
local rendering = require('rendering')
local StackContainer = require('ui.stack_container')
local TextWidget = require('ui.text_widget')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local module = {}

local function make_item_ui(index, item)
    assert(item)
    local tileset = globals.tileset
    local icon_name = rendering.icon_name_for_item(item)
    local tileset_x = tileset.icons[icon_name].x
    local tileset_y = tileset.icons[icon_name].y
    return StackContainer.new({
            padding = {
                left = ui_scaled(16),
                right = ui_scaled(16),
                top = ui_scaled(8),
                bottom = ui_scaled(8)
            },
            orientation = StackContainer.Orientation.VERTICAL,
            children = {
                TextWidget.new({
                        layout = {
                            center_horizontally = true
                        },
                        text = tostring(index),
                        font = fonts.get(ui_scaled(24))
                }),
                FrameContainer.new({
                        layout = {
                            center_horizontally = true
                        },
                        border = {
                            color = colors.WHITE
                        },
                        children = {
                            ImageWidget.new({
                                    padding = ui_scaled(8),
                                    texture = tileset.image,
                                    -- FIXME: cache quad
                                    quad = love.graphics.newQuad(
                                        tileset_x * tileset.tile_width,
                                        tileset_y * tileset.tile_height,
                                        tileset.tile_width,
                                        tileset.tile_height,
                                        tileset.image:getWidth(),
                                        tileset.image:getHeight()
                                    ),
                                    color = rendering.color_for_item(item),
                                    scaled_width = ui_scaled(32),
                                    scaled_height = ui_scaled(32)
                            }),
                            TextWidget.new({
                                    layout = {
                                        align_right = true,
                                        align_bottom = true
                                    },
                                    padding = {
                                        right = ui_scaled(4)
                                    },
                                    text = tostring(item.quantity),
                                    font = fonts.get(ui_scaled(16))
                            })
                        }
                }),
                TextWidget.new({
                        layout = {
                            center_horizontally = true
                        },
                        padding = {
                            top = ui_scaled(4)
                        },
                        text = module.make_item_name(item),
                        font = fonts.get(ui_scaled(18))
                })
            }
    })
end

function module.make_item_name(item)
    assert(item)
    local name

    if item.kind == Item.Kind.ARROWS then
        name = 'Arrows'
    elseif item.kind == Item.Kind.POTION then
        name = 'Potion'
    elseif item.kind == Item.Kind.FIRE_WAND then
        name = 'Fire wand'
    elseif item.kind == Item.Kind.DEATH_WAND then
        name = 'Death wand'
    elseif item.kind == Item.Kind.ICE_WAND then
        name = 'Ice wand'
    end

    assert(name)
    return name
end

function module.draw()
    local items = globals.hero.inventory.items
    local row = StackContainer.new({
            orientation = StackContainer.Orientation.HORIZONTAL,
            children = array_utils.map_with_index(
                items,
                function(index, item)
                    return make_item_ui(index, item)
                end
            )
    })
    local root = row
    root:measure()
    local x = math.floor((love.graphics.getWidth() - root:width()) / 2)
    local y = math.floor(love.graphics.getHeight() - root:height())
    root:draw(x, y)
end

return module
