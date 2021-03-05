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

local game_logic = require('game_logic')
local TargetEventHandler = require('target_event_handler')
local utils = require('utils')

local super = TargetEventHandler
local class = setmetatable({}, { __index = super })

local FIRE_WAND_DAMAGE = 2
local FIRE_WAND_RANGE = 3

local function on_tile_selected(self, tile)
    if tile.unit and not tile.unit.is_hero then
        game_logic.attack(
            globals.hero,
            tile.unit,
            FIRE_WAND_DAMAGE,
            globals.map,
            globals.enemies
        )
        globals.hero.inventory:decrease_quantity(self.item_index)
        game_logic.take_enemy_turns(globals.enemies, globals.map)
        self:exit()
    end
end

function class.new(item_index)
    assert(item_index)
    local instance = {
        item_index = item_index
    }
    super._init(instance, FIRE_WAND_RANGE, on_tile_selected)
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string(
            'FireWandEventHandler',
            'item_index'
        )
    }
    return setmetatable(instance, metatable)
end

return class
