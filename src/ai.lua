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
local fov = require('fov')
local Vec2 = require('vec2')

local module = {}

local function move_toward(unit, x, y)
    assert(unit)
    assert(x)
    assert(y)
    assert(unit.position.x ~= x or unit.position.y ~= y)
    local position = unit.position
    local new_x = nil
    local new_y = nil

    local function try_horizontal_move()
        if new_y == nil then
            if position.x < x then
                new_x = position.x + 1
            elseif position.x > x then
                new_x = position.x - 1
            end
        end
    end

    local function try_vertical_move()
        if new_x == nil then
            if position.y < y then
                new_y = position.y + 1
            elseif position.y > y then
                new_y = position.y - 1
            end
        end
    end

    if love.math.random(0, 1) == 0 then
        try_horizontal_move()
        try_vertical_move()
    else
        try_vertical_move()
        try_horizontal_move()
    end

    assert(new_x or new_y)
    new_x = new_x or position.x
    new_y = new_y or position.y
    local game_logic = require('game_logic')
    game_logic.attempt_move_unit(
        unit,
        Vec2.new(new_x, new_y),
        globals.map
    )
end

function module.take_enemy_turn(enemy, map)
    assert(enemy)
    assert(map)
    assert(not enemy:is_hero())
    assert(array_utils.contains(globals.enemies, enemy))

    for x, y, tile in fov.visible_tiles(enemy, map) do
        if tile.unit and tile.unit:is_hero() then
            move_toward(enemy, x, y)
            break
        end
    end
end

return module
