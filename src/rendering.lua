local FovStatus = require('./fov_status')
local Item = require('./item')
local Tile = require('./tile')

local module = {}

local function tileset_coordinates(tile)
    assert(tile)
    local tileset_x
    local tileset_y

    if tile.unit and tile.fov_status == FovStatus.IN_SIGHT then
        local unit = tile.unit

        if unit.is_hero then
            tileset_x = 27
            tileset_y = 0
        else
            tileset_x = 28
            tileset_y = 0
        end
    elseif tile.item then
        if tile.item.kind == Item.Kind.ARROWS then
            tileset_x = 42
            tileset_y = 6
        end
    elseif tile.kind == Tile.Kind.NOTHING then
        tileset_x = 2
        tileset_y = 0
    elseif tile.kind == Tile.Kind.WALL then
        tileset_x = 0
        tileset_y = 13
    elseif tile.kind == Tile.Kind.STAIRS then
        tileset_x = 3
        tileset_y = 6
    elseif tile.kind == Tile.Kind.BOOKSHELF then
        tileset_x = 3
        tileset_y = 7
    end

    assert(tileset_x, string.format('No tileset X for %s', tile.kind))
    assert(tileset_y, string.format('No  tileset Y for %s', tile.kind))
    return tileset_x, tileset_y
end

function module.draw_tile(x, y, tile)
    assert(x)
    assert(y)
    assert(tile)

    if FOV_ENABLED and tile.fov_status == FovStatus.UNEXPLORED then
        return
    end

    local tileset_x, tileset_y = tileset_coordinates(tile)
    local quad = love.graphics.newQuad(
        tileset_x * tileset.tile_width,
        tileset_y * tileset.tile_height,
        tileset.tile_width,
        tileset.tile_height,
        tileset.image:getWidth(),
        tileset.image:getHeight()
    )
    local alpha

    if tile.fov_status == FovStatus.IN_SIGHT then
        alpha = 1
    elseif tile.fov_status == FovStatus.EXPLORED then
        alpha = 0.3
    end

    assert(alpha)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(
        tileset.image,
        quad,
        x * tileset.tile_width * camera.scale,
        y * tileset.tile_height * camera.scale,
        0, -- rotation
        camera.scale,
        camera.scale
    )
end

return module
