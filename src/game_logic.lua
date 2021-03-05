-- Game logic functions that don't belong (yet) to another file

local ai = require('./ai')
local array_utils = require('./array_utils')
local fov = require('./fov')
local Item = require('./item')
local map_generator = require('./map_generator')
local Position = require('./position')
local Tile = require('./tile')
local utils = require('./utils')

local module = {}

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
        if FOV_ENABLED then
            fov.update_fov(map, hero)
        end

        camera:center(hero.position)
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

    if unit.is_hero then
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

local function attack(attacker, victim, map, enemies)
    assert(attacker)
    assert(victim)
    assert(map)
    assert(enemies)
    victim.health:dec()

    if victim.health:is_dead() then
        if victim.is_hero then
            error('You died')
        else
            local victim_position = victim.position
            remove_unit(victim, map, enemies)

            if not victim.is_hero then
                remove_enemy(victim, enemies)
            end

            -- Do we want the player to move on a tile after killing its unit?
            -- move_unit(attacker, victim_position, map, enemies)
        end
    end
end

local function take_enemy_turns(enemies, map)
    assert(enemies)
    assert(map)

    -- TODO: iterate on a copy in case the AI gets an enemy killed
    for _, enemy in ipairs(enemies) do
        assert(not enemy.health:is_dead())
        ai.take_enemy_turn(enemy, map)
    end
end

function module.enter_new_level(hero)
    print('Entering new level')
    assert(hero)
    hero.position = nil
    local rooms
    map, rooms, hero_position, enemies = map_generator.generate_map()
    put_unit(hero, hero_position, map)
    on_hero_move(hero, map:get_tile(hero.position))
end

-- FIXME: use actions instead (will prefer enemies from moving diagonally)
function module.attempt_move_unit(unit, new_position, map)
    assert(unit)
    assert(new_position)
    assert(map)
    assert(not unit.health:is_dead())
    local tile = map:get_tile(new_position)
    local skip_enemy_turns = false

    if tile:walkable() then
        skip_enemy_turns = move_unit(unit, new_position, map, enemies)
    elseif tile.unit then
        local victim = tile.unit

        if unit.is_hero or victim.is_hero then
            attack(unit, victim, map, enemies)
        end
    end

    if not skip_enemy_turns and unit.is_hero then
        take_enemy_turns(enemies, map)
    end
end

local ArrowEventHandler = {}
function ArrowEventHandler.new(item_index)
    assert(item_index)
    local instance = {
        item_index = item_index,
        cursor_position = hero.position
    }
    local metatable = {
        __index = ArrowEventHandler,
        __tostring = utils.make_to_string(
            'ArrowEventHandler',
            'item_index',
            'cursor_position'
        )
    }
    return setmetatable(instance, metatable)
end
function ArrowEventHandler:on_key_pressed(key, scancode, is_repeat, exit)
    if key == 'escape' then
        exit()
        return
    end

    if key == 'return' then
        local tile = map:get_tile_or_nil(self.cursor_position)

        if tile and tile.unit and not tile.unit.is_hero then
            -- FIXME: spend turn (let enemies move)
            attack(hero, tile.unit, map, enemies)
            hero.inventory:decrease_quantity(self.item_index)
            exit()
            return
        end
    end

    local directions = {
        left = Position.new(-1, 0),
        right = Position.new(1, 0),
        up = Position.new(0, -1),
        down = Position.new(0, 1)
    }

    for direction, position in pairs(directions) do
        if direction == key then
            self.cursor_position = self.cursor_position:plus(position)
            break
        end
    end
end

function module.use_item(hero, item_index)
    assert(hero)
    assert(item_index)
    local item = hero.inventory.items[item_index]

    if item then
        if item.kind == Item.Kind.ARROWS then
            event_handlers_stack:push(ArrowEventHandler.new(item_index))
        else
            error(string.format('Unandled item kind %s', item.kind))
        end
    end
end

function module.push_event_handler(handler)
    assert(handler)
    handler.exit = function()
        event_handlers_stack:pop()
    end
    event_handlers_stack:push(handler)
end

return module
