local FovStatus = require('./fov_status')
local TileKind = require('./tile_kind')
local utils = require('./utils')

local class = {}
class.Kind = TileKind

function class.new()
    local fov_status

    if FOV_ENABLED then
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
        __tostring = utils.make_to_string('Tile', 'kind', 'unit', 'fov_status')
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
