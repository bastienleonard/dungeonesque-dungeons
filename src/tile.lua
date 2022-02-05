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

local FovStatus = require('fov_status')
local TileKind = require('tile_kind')
local utils = require('utils')

local class = {}
class.Kind = TileKind

function class.new()
    local fov_status

    if globals.FOV_ENABLED then
        fov_status = FovStatus.UNEXPLORED
    else
        fov_status = FovStatus.IN_SIGHT
    end

    assert(fov_status)
    local instance = {
        kind = class.Kind.NOTHING,
        unit = nil,
        item = nil,
        fov_status = fov_status
    }
    local metatable = {
        __index = class,
        __tostring = utils.make_to_string(
            'Tile',
            'kind',
            'unit',
            'item',
            'fov_status'
        )
    }
    return setmetatable(instance, metatable)
end

function class:walkable()
    return self.unit == nil and self.kind.walkable
end

function class:blocks_sight()
    return self.kind.blocks_sight
end

return class
