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

-- Game logic functions that don't belong (yet) to another file

local ai = require('ai')
local array_utils = require('array_utils')
local DeathScreen = require('death_screen')
local fov = require('fov')
local Item = require('item')
local map_generator = require('map_generator.map_generator')
local Tile = require('tile')
local UnitStatus = require('unit_status')

local module = {}

local ATTACK_DAMAGE = 1

local function on_turn_elapsed()
    for _, unit in ipairs(globals.enemies) do
        unit.statuses:on_turn_elapsed()
    end

    globals.hero.statuses:on_turn_elapsed()
end

local function heal(unit, amount)
    assert(unit)
    assert(amount)
    unit.health:inc(amount)
end

local function on_hero_move(hero, tile)
    assert(hero)
    assert(tile)
    local skip_enemy_turns = false

    if tile.item then
        hero.inventory:add(tile.item)
        tile.item = nil
    end

    if tile.kind == Tile.Kind.STAIRS then
        skip_enemy_turns = true
        module.enter_new_level(hero)
    else
        if globals.FOV_ENABLED then
            fov.update_fov(globals.map, hero)
        end

        globals.camera:center_on_map_position(hero.position)
    end

    return skip_enemy_turns
end

local function put_unit(unit, position, map)
    assert(unit)
    assert(position)
    assert(map)
    local tile = map:get_tile(position)
    assert(tile.unit == nil)
    unit.position = position
    map:get_tile(unit.position).unit = unit
end

local function remove_unit(unit, map, enemies)
    assert(unit)
    assert(map)
    assert(enemies)
    assert(unit.position)
    local tile = map:get_tile(unit.position)
    assert(tile.unit == unit)
    tile.unit = nil
end

local function move_unit(unit, new_position, map, enemies)
    assert(unit)
    assert(new_position)
    assert(map)
    assert(enemies)
    remove_unit(unit, map, enemies)
    put_unit(unit, new_position, map)
    local skip_enemy_turns = false

    if unit:is_hero() then
        skip_enemy_turns = on_hero_move(unit, map:get_tile(unit.position), map)
    end

    return skip_enemy_turns
end

local function remove_enemy(enemy, enemies)
    assert(enemy)
    assert(enemies)
    assert(enemy.health:is_dead())
    local enemies_count = #enemies
    assert(array_utils.remove(enemies, enemy).health:is_dead())
    assert(enemies_count == #enemies + 1)
end

function module.take_enemy_turns(enemies, map)
    assert(enemies)
    assert(map)

    -- TODO: iterate on a copy in case the AI gets an enemy killed
    for _, enemy in ipairs(enemies) do
        assert(not enemy.health:is_dead())
        ai.take_enemy_turn(enemy, map)
    end

    on_turn_elapsed()
end

function module.attack(attacker, victim, damage, map, enemies)
    assert(attacker)
    assert(victim)
    assert(damage)
    assert(map)
    assert(enemies)

    if not (globals.INVINCIBILITY_ENABLED and victim:is_hero()) then
        victim.health:dec(damage)
    end

    if victim.health:is_dead() then
        if victim:is_hero() then
            globals.screens:replace_last(DeathScreen.new())
        else
            local victim_position = victim.position
            remove_unit(victim, map, enemies)

            if not victim:is_hero() then
                remove_enemy(victim, enemies)
            end
        end
    end
end

function module.enter_new_level(hero)
    print('Entering new level')
    assert(hero)
    hero.position = nil
    globals.level_counter = globals.level_counter + 1
    local rooms
    local hero_position
    globals.map,
        rooms,
        hero_position,
        globals.enemies = map_generator.generate_map()
    put_unit(globals.hero, hero_position, globals.map)
    on_hero_move(globals.hero, globals.map:get_tile(hero.position))
end

function module.attempt_move_unit(unit, new_position, map)
    assert(unit)
    assert(new_position)
    assert(map)
    assert(not unit.health:is_dead())
    local tile = map:get_tile(new_position)
    local skip_enemy_turns = true

    if tile:walkable() and not unit.statuses:has(UnitStatus.FROZEN) then
        skip_enemy_turns = move_unit(unit, new_position, map, globals.enemies)
    elseif tile.unit then
        local victim = tile.unit

        if unit:is_hero() or victim:is_hero() then
            module.attack(
                unit,
                victim,
                ATTACK_DAMAGE,
                globals.map,
                globals.enemies
            )
            skip_enemy_turns = false
        end
    end

    if not skip_enemy_turns and unit:is_hero() then
        module.take_enemy_turns(globals.enemies, globals.map)
    end
end

function module.use_item(hero, item_index)
    assert(hero)
    assert(item_index)
    local item = globals.hero.inventory.items[item_index]

    if item then
        if item.kind == Item.Kind.ARROWS then
            local ArrowEventHandler = require('arrow_event_handler')
            globals.push_event_handler(ArrowEventHandler.new(item_index))
        elseif item.kind == Item.Kind.POTION then
            if not hero.health:is_full() then
                heal(globals.hero, 5)
                globals.hero.inventory:decrease_quantity(item_index)
                module.take_enemy_turns(globals.enemies, globals.map)
            end
        elseif item.kind == Item.Kind.FIRE_WAND then
            local FireWandEventHandler = require('fire_wand_event_handler')
            globals.push_event_handler(FireWandEventHandler.new(item_index))
        elseif item.kind == Item.Kind.DEATH_WAND then
            local DeathWandEventHandler = require('death_wand_event_handler')
            globals.push_event_handler(DeathWandEventHandler.new(item_index))
        elseif item.kind == Item.Kind.ICE_WAND then
            local IceWandEventHandler = require('ice_wand_event_handler')
            globals.push_event_handler(IceWandEventHandler.new(item_index))
        else
            error(string.format('Unhandled used item kind %s', item.kind))
        end
    end
end

return module
