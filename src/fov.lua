local FovStatus = require('./fov_status')

local module = {}

local function area(position)
    assert(position)
    local result = {}
    local size = 5

    for x = position.x - size, position.x + size do
        for y = position.y - size, position.y + size do
            local tile = map:get_tile_or_nil(x, y)

            if tile then
                table.insert(result, { x, y, tile })
            end
        end
    end

    local i = 0
    return function()
        i = i + 1

        if i > #result then
            return nil
        end

        local item = result[i]
        return item[1], item[2], item[3]
    end
end

function module.visible_tiles(unit, map)
    assert(unit)
    assert(map)
    local result = {}

    -- Totally incorrect, but decent enough for now!
    for x, y, tile in area(unit.position) do
        table.insert(result, { x, y, tile })
    end

    local i = 0
    return function()
        i = i + 1

        if i > #result then
            return nil
        end

        local item = result[i]
        return item[1], item[2], item[3]
    end
end

function module.update_fov(map, hero)
    assert(map)
    assert(hero)

    for x, y, tile in map:iter() do
        if tile.fov_status == FovStatus.IN_SIGHT then
            tile.fov_status = FovStatus.EXPLORED
        end
    end

    local function neighbor(x, y)
        assert(x)
        assert(y)
        assert(map)

        if hero.position.x < x then
            x = x - 1
        elseif hero.position.x > x then
            x = x + 1
        end

        if hero.position.y < y then
            y = y - 1
        elseif hero.position.y > y then
            y = y + 1
        end

        return x, y, map:get_tile(x, y)
    end

    local function is_visible(x, y)
        assert(x)
        assert(y)

        if x == hero.position.x and y == hero.position.y then
            return true
        end

        local x, y, tile = neighbor(x, y)
        return not tile:blocks_sight() and is_visible(x, y)
    end

    for x, y, tile in area(hero.position) do
        if is_visible(x, y) then
            tile.fov_status = FovStatus.IN_SIGHT
        end
    end
end

return module
