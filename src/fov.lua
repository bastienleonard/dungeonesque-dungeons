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

local FovStatus = require('fov_status')

local FOV_RADIUS = 8
local module = {}

local function fov_area(position)
    assert(position)
    local result = {}

    for x = position.x - FOV_RADIUS, position.x + FOV_RADIUS do
        for y = position.y - FOV_RADIUS, position.y + FOV_RADIUS do
            local tile = globals.map:get_tile_or_nil(x, y)

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
    for x, y, tile in fov_area(unit.position) do
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

    for x, y, tile in fov_area(hero.position) do
        if is_visible(x, y) then
            tile.fov_status = FovStatus.IN_SIGHT
        end
    end
end

return module
