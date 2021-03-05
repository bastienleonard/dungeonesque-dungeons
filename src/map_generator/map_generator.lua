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
local Item = require('item')
local Map = require('map')
local random = require('random')
local Room = require('map_generator.room')
local Tile = require('tile')
local Unit = require('unit')
local Vec2 = require('vec2')

local module = {}

local MIN_MAP_SIZE = 20
local MAX_MAP_SIZE = 100

local function usable_size(rooms)
    assert(rooms)
    return array_utils.sum(
        array_utils.map(
            rooms,
            function(room)
                -- FIXME: use usable_tiles_count()
                return room.width * room.height
            end
        )
    )
end

local function neighbors(map, x, y)
    assert(map)
    assert(x)
    assert(y)

    local function possible_neighbors()
        return {
            { x - 1, y },
            { x + 1, y },
            { x, y - 1 },
            { x, y + 1 }
        }
    end

    local result = {}

    for _, p in ipairs(possible_neighbors()) do
        if map:get_tile_or_nil(p[1], p[2]) then
            table.insert(result, { p[1], p[2] })
        end
    end

    return result
end

-- FIXME: validate that all rooms have no intersections between each other
local function random_room_tile(room, map, padding)
    assert(room)
    assert(map)
    padding = padding or 0
    local coords = random.choice(room:all_coords(-1 - padding))
    local x = coords[1]
    local y = coords[2]
    return x, y, map:get_tile(x, y)
end

local function put_wall(map, x, y)
    assert(map)
    assert(x)
    assert(y)
    map:get_tile(x, y).kind = Tile.Kind.WALL
end

local function put_wall_line(map, x1, y1, x2, y2)
    assert(map)
    assert(x1)
    assert(y1)
    assert(x2)
    assert(y2)

    if x1 ~= x2 and y1 ~= y2 then
        error(
            string.format(
                'Not a horizontal or vertical line: (%s,%s) -> (%s,%s)',
                x1,
                y1,
                x2,
                y2
            )
        )
    end

    local x = x1
    local y = y1

    while true do
        put_wall(map, x, y)

        if x < x2 then
            x = x + 1
        elseif x > x2 then
            x = x - 1
        elseif y < y2 then
            y = y + 1
        elseif y > y2 then
            y = y - 1
        else
            break
        end
    end
end

local function place_room(map, room)
    assert(map)
    assert(room)
    put_wall_line(map, room.x, room.y, room.x + room.width, room.y)
    put_wall_line(
        map,
        room.x, room.y + room.height,
        room.x + room.width,
        room.y + room.height
    )
    put_wall_line(map, room.x, room.y, room.x, room.y + room.height)
    put_wall_line(
        map,
        room.x + room.width,
        room.y,
        room.x + room.width,
        room.y + room.height
    )
end

local function is_room_valid(room, map)
    assert(room)
    assert(map)

    for _, coords in ipairs(room:all_coords(1)) do
        local x = coords[1]
        local y = coords[2]
        local tile = map:get_tile_or_nil(x, y)

        if tile == nil or tile.kind ~= Tile.Kind.NOTHING then
            return false
        end
    end

    return true
end

local function random_room(map, options)
    assert(map)
    options = options or {}
    local width = options.width or love.math.random(8, 12)
    local height = options.height or love.math.random(8, 12)
    local x = options.x or love.math.random(0, map.width - width - 1)
    local y = options.y or love.math.random(0, map.height - height - 1)
    return Room.new(
        x,
        y,
        width,
        height
    )
end

local function room_connected_to(other_room, map)
    assert(other_room)
    assert(map)
    local distance = love.math.random(5, 10)
    local coordinate_changes = {
        function(room) return room:right() + distance, room.y end,
        function(room) return room.x - distance - room.width, room.y end,
        function(room) return room.x, room.y - distance - room.height end,
        function(room) return room.x, room:bottom() + distance end
    }
    random.shuffle(coordinate_changes)

    for _, f in ipairs(coordinate_changes) do
        local x, y = f(other_room)
        local room = random_room(map, { x = x, y = y })

        -- TODO: try a few different random rooms before giving up?

        if is_room_valid(room, map) then
            return room
        end
    end

    return nil
end

local function place_hall(map, first_room, second_room)
    assert(map)
    assert(first_room)
    assert(second_room)
    local horizontal_connection = first_room.y == second_room.y

    if horizontal_connection then
        if second_room.x < first_room.x then
            first_room, second_room = second_room, first_room
        end

        local y = math.floor(first_room.y + (first_room.height / 2))
        put_wall_line(
            map,
            first_room:right(),
            y - 1,
            second_room.x,
            y - 1
        )
        map:get_tile(first_room:right(), y).kind = Tile.Kind.NOTHING
        map:get_tile(second_room.x, y).kind = Tile.Kind.NOTHING
        put_wall_line(
            map,
            first_room:right(),
            y + 1,
            second_room.x,
            y + 1
        )
    else
        if second_room.y < first_room.y then
            first_room, second_room = second_room, first_room
        end

        local x = math.floor(first_room.x + (first_room.width / 2))
        put_wall_line(
            map,
            x - 1,
            first_room:bottom(),
            x - 1,
            second_room.y
        )
        map:get_tile(x, first_room:bottom()).kind = Tile.Kind.NOTHING
        map:get_tile(x, second_room.y).kind = Tile.Kind.NOTHING
        put_wall_line(
            map,
            x + 1,
            first_room:bottom(),
            x + 1,
            second_room.y
        )
    end
end

local function place(map, rooms, count, tile_fits, update_tile)
    assert(map)
    assert(rooms)
    assert(count)

    for i = 1, count do
        -- FIXME
        while true do
            local room = random.choice(rooms)
            local x, y, tile = random_room_tile(room, map, 1)

            if tile_fits(tile, x, y, neighbors(map, x, y)) then
                update_tile(tile, x, y)
                break
            end
        end
    end
end

-- FIXME: guarantee that stairs don't become surrounded by decorations
local function place_stairs(map, rooms)
    assert(map)
    assert(rooms)
    local count = math.max(
        1,
        math.floor(usable_size(rooms) / 400)
    )
    print(string.format('Placing %s stairs', count))
    place(
        map,
        rooms,
        count,
        function(tile)
            return tile.kind == Tile.Kind.NOTHING
        end,
        function(tile, x, y)
            tile.kind = Tile.Kind.STAIRS
        end
    )
end

local function place_decorations(map, rooms)
    assert(map)
    assert(rooms)

    local function tile_fits(tile, x, y, neighbors)
        return tile.kind == Tile.Kind.NOTHING
            and array_utils.none(
                neighbors,
                function(coord)
                    local tile = map:get_tile(coord[1], coord[2])
                    return not tile.kind == Tile.Kind.STAIRS
                end
                                )
    end

    place(
        map,
        rooms,
        math.floor(usable_size(rooms) / 30),
        tile_fits,
        -- function(tile)
        --     return tile.kind == Tile.Kind.NOTHING
        -- end,
        function(tile, x, y)
            tile.kind = Tile.Kind.BOOKSHELF
        end
    )
    place(
        map,
        rooms,
        math.floor(usable_size(rooms) / 80),
        tile_fits,
        -- function(tile)
        --     return tile.kind == Tile.Kind.NOTHING
        -- end,
        function(tile, x, y)
            tile.kind = Tile.Kind.BOOKSHELF_WITH_SKULL
        end
    )
end

local function place_enemies(map, rooms)
    assert(map)
    assert(rooms)
    local enemies_count = math.max(
        1,
        math.floor(usable_size(rooms) / 100)
    )
    print(string.format('Placing %s enemy(ies)', enemies_count))
    local enemies = {}
    place(
        map,
        rooms,
        enemies_count,
        function(tile)
            -- FIXME: check item?
            return tile.kind == Tile.Kind.NOTHING and tile.unit == nil
        end,
        function(tile, x, y)
            local enemy = Unit.new_enemy(Vec2.new(x, y))
            tile.unit = enemy
            table.insert(enemies, enemy)
        end
    )
    return enemies
end

local function place_items(map, rooms)
    print('Placing items')
    assert(map)
    assert(rooms)

    local function place_item_kind(item_kind, count)
        assert(item_kind)
        assert(count)
        print(string.format('Placing %s %s', count, item_kind))
        place(
            map,
            rooms,
            count,
            function(tile)
                return tile.kind == Tile.Kind.NOTHING
                    and tile.unit == nil
                    and tile.item == nil
            end,
            function(tile, x, y)
                assert(not tile.item)
                tile.item = Item.new_from_kind(item_kind)
            end
        )
    end

    if globals.ARROWS_ENABLED then
        place_item_kind(
            Item.Kind.ARROWS,
            math.max(
                0,
                math.floor(usable_size(rooms) / 10)
            )
        )
    end

    place_item_kind(
        Item.Kind.POTION,
        math.max(
            0,
            math.floor(usable_size(rooms) / 150)
        )
    )
    place_item_kind(
        Item.Kind.FIRE_WAND,
        math.max(
            0,
            math.floor(usable_size(rooms) / 200)
        )
    )
    place_item_kind(
        Item.Kind.DEATH_WAND,
        math.max(
            0,
            math.floor(usable_size(rooms) / 400)
        )
    )
    place_item_kind(
        Item.Kind.ICE_WAND,
        math.max(
            0,
            math.floor(usable_size(rooms) / 150)
        )
    )
end

local function place_hero(map, rooms)
    assert(map)
    assert(rooms)
    local hero_position = nil
    local first_and_last_rooms = { rooms[1], array_utils.last(rooms) }

    for _, room in ipairs(random.shuffled(first_and_last_rooms)) do
        local x, y, tile = random_room_tile(room, map)

        if tile.kind == Tile.Kind.NOTHING
            and tile.unit == nil
            and tile.item == nil then
            hero_position = Vec2.new(x, y)
            break
        end
    end

    assert(hero_position)
    return hero_position
end

function module.generate_map()
    local level = globals.level_counter
    local size = math.min(
        MIN_MAP_SIZE + (level - 1) * 10,
        MAX_MAP_SIZE
    )
    local map = Map.new({
            width = size,
            height = size,
            default_tile = function() return Tile.new() end
    })
    print(string.format('Map size: %sx%s', map.width, map.height))
    local previous_room = random_room(map)
    place_room(map, previous_room)
    local rooms = { previous_room }

    while true do
        local room = room_connected_to(previous_room, map)

        if not room then
            -- FIXME: try to connect to other rooms before giving up
            break
        end

        table.insert(rooms, room)
        place_room(map, room)
        place_hall(map, room, previous_room)
        previous_room = room
    end

    place_stairs(map, rooms)
    place_decorations(map, rooms)
    local enemies = place_enemies(map, rooms)
    place_items(map, rooms)
    local hero_position = place_hero(map, rooms)
    return map, rooms, hero_position, enemies
end

return module
