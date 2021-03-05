local array_utils = require('./array_utils')
local fov = require('./fov')
local Position = require('./position')

local module = {}

local function move_towards(unit, x, y)
    assert(unit)
    assert(x)
    assert(y)
    assert(unit.position.x ~= x or unit.position.y ~= y)
    local position = unit.position
    local new_x = nil
    local new_y = nil

    if position.x < x then
        new_x = position.x + 1
    elseif position.x > x then
        new_x = position.x - 1
    end

    if position.y < y then
        new_y = position.y + 1
    elseif position.y > y then
        new_y = position.y - 1
    end

    assert(new_x or new_y)
    new_x = new_x or position.x
    new_y = new_y or position.y
    local game_logic = require('./game_logic')
    game_logic.attempt_move_unit(
        unit,
        Position.new(new_x, new_y),
        map
    )
end

function module.take_enemy_turn(enemy, map)
    assert(enemy)
    assert(map)
    assert(not enemy.is_hero)
    assert(array_utils.contains(enemies, enemy))
    print('Enemy takes turn')

    for x, y, tile in fov.visible_tiles(enemy, map) do
        if tile.unit and tile.unit.is_hero then
            move_towards(enemy, x, y)
            break
        end
    end
end

return module
