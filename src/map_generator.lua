local Item = require('./item')
local Map = require('./map')
local Position = require('./position')
local random = require('./random')
local Tile = require('./tile')
local Unit = require('./unit')
local utils = require('./utils')

local module = {}

local Room = {}

-- The will extend 1 past x + width and y + height
function Room.new(x, y, width, height)
    assert(x)
    assert(y)
    assert(width)
    assert(height)
    local instance = {
        x = x,
        y = y,
        width = width,
        height = height
    }
    local metatable = {
        __index = Room,
        __tostring = utils.make_to_string('Room', 'x', 'y', 'width', 'height')
    }
    return setmetatable(instance, metatable)
end

function Room:right()
    return self.x + self.width
end

function Room:bottom()
    return self.y + self.height
end

function Room:center()
    return Position.new(
        math.floor(self.x + self.width / 2),
        math.floor(self.y + self.height / 2)
    )
end

function Room:all_coords(padding)
    padding = padding or 0
    local result = {}

    for x = self.x - padding, self.x + self.width + padding do
        for y = self.y - padding, self.y + self.height + padding do
            table.insert(result, { x, y })
        end
    end

    return result
end

function module.generate_map()
    local map = Map.new({
            width = 40,
            height = 40,
            default_tile = function() return Tile.new() end
    })
    local rooms_count = math.floor(map.width * map.height / 500)

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

    local function random_room(options)
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

    local previous_room = random_room()
    place_room(map, previous_room)
    local rooms = { previous_room }

    local function room_connected_to(other_room, map)
        assert(other_room)
        assert(map)
        local coordinate_changes = {
            function(room) return room:right() + 10, room.y end,
            function(room) return room.x - 10 - room.width, room.y end,
            function(room) return room.x, room.y - 10 - room.height end,
            function(room) return room.x, room:bottom() + 10 end
        }
        random.shuffle(coordinate_changes)

        for _, f in ipairs(coordinate_changes) do
            local x, y = f(other_room)
            local room = random_room({ x = x, y = y })

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

    for i = 1, rooms_count - 1 do
        local room = room_connected_to(previous_room, map)

        if not room then
            print('Failed to find a room')
            break
        end

        table.insert(rooms, room)
        place_room(map, room)
        place_hall(map, room, previous_room)
        previous_room = room
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

    -- TODO: guarantee that stairs don't become surrounded by objects
    local function place_stairs(map, rooms)
        assert(map)
        assert(rooms)
        local stairs_count = math.max(
            1,
            math.floor(map.width * map.height / 1000)
        )

        for i = 1, stairs_count do
            local failure = true

            for j = 1, 1000 do
                local room = random.choice(rooms)
                local x, y, tile = random_room_tile(room, map, 1)

                if tile.kind == Tile.Kind.NOTHING then
                    tile.kind = Tile.Kind.STAIRS
                    failure = false
                    break
                end
            end

            if failure then
                print('Failed to find tile for stairs')
                break
            end
        end
    end

    place_stairs(map, rooms)

    local function place_decorations(map, rooms)
        assert(map)
        assert(rooms)
        local decorations_count = math.floor(map.width * map.height / 200)

        for i = 1, decorations_count do
            local failure = true

            for j = 1, 1000 do
                local room = random.choice(rooms)
                local x, y, tile = random_room_tile(room, map, 1)

                if tile.kind == Tile.Kind.NOTHING then
                    tile.kind = Tile.Kind.BOOKSHELF
                    failure = false
                    break
                end
            end

            if failure then
                print('Failed to find tile for decoration')
                break
            end
        end
    end

    place_decorations(map, rooms)

    local function place_enemies(map, rooms)
        assert(map)
        assert(rooms)
        local enemies_count = math.max(
            1,
            math.floor(map.width * map.height / 500)
        )
        local enemies = {}

        for i = 1, enemies_count do
            local room = random.choice(rooms)
            local x, y, tile = random_room_tile(room, map)

            -- TODO: retry if the tile was not empty
            if tile.kind == Tile.Kind.NOTHING and tile.unit == nil then
                local enemy = Unit.new_enemy(Position.new(x, y))
                tile.unit = enemy
                table.insert(enemies, enemy)
            end
        end

        return enemies
    end

    local enemies = place_enemies(map, rooms)

    local function place_objects(map, rooms)
        assert(map)
        assert(rooms)

        local function place_arrows()
            local arrows_count = math.max(
                1,
                math.floor(map.width * map.height / 100)
            )

            for _ = 1, arrows_count do
                local room = random.choice(rooms)
                local x, y, tile = random_room_tile(room, map)

                -- TODO: retry if the tile was not empty
                if tile.kind == Tile.Kind.NOTHING
                    and tile.unit == nil
                    and tile.object == nil then
                    tile.item = Item.new_arrows()
                end
            end
        end

        place_arrows()
    end

    place_objects(map, rooms)
    local hero_position

    while true do
        local room = random.choice(rooms)
        local x, y, tile = random_room_tile(room, map)

        if tile.kind == Tile.Kind.NOTHING
            and tile.unit == nil
            and tile.object == nil then
            hero_position = Position.new(x, y)
            break
        end
    end

    return map, rooms, hero_position, enemies
end

return module
