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

local utils = require('utils')

local class = {}

local function is_in_bounds(self, x, y)
    assert(self)
    assert(x)
    assert(y)
    return not (x < 0 or x >= self.width or y < 0 or y >= self.height)
end

local function check_bounds(self, x, y)
    assert(self)
    assert(x)
    assert(y)

    if not is_in_bounds(self, x, y) then
        error(
            string.format(
                '(%s,%s) is out of bounds %sx%s',
                x,
                y,
                self.width,
                self.height
            )
        )
    end
end

function class.new(options)
    local width = options.width
    assert(width)
    local height = options.height
    assert(height)
    local default_tile = options.default_tile
    assert(default_tile)
    local tiles = {}

    for i = 1, width * height do
        local tile

        if type(default_tile) == 'function' then
            tile = default_tile()
        else
            tile = default_tile
        end

        table.insert(tiles, tile)
    end

    local instance = {
        width = width,
        height = height,
        _tiles = tiles
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string('Map', 'width', 'height')
    }
    return setmetatable(instance, metatable)
end

function class:get_tile_or_nil(x, y)
    assert(x)

    if not y then
        y = x.y
        x = x.x
    end

    if not is_in_bounds(self, x, y) then
        return nil
    end

    return self:get_tile(x, y)
end

function class:get_tile(x, y)
    assert(x)

    if not y then
        y = x.y
        x = x.x
    end

    check_bounds(self, x, y)
    local tile = self._tiles[1 + x + y * self.width]
    assert(tile ~= nil)
    return tile
end

function class:contains(x, y)
    assert(x)
    assert(y)
    return is_in_bounds(self, x, y)
end

function class:iter()
    local x = -1
    local y = 0
    return function()
        x = x + 1

        if x == self.width then
            x = 0
            y = y + 1

            if y == self.height then
                return nil
            end
        end

        local tile = self:get_tile(x, y)
        return x, y, tile
    end
end

return class
