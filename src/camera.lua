local class = {}

function class.new()
    local instance = {
        x = 0,
        y = 0,
        scale = 4
    }
    local metatable = {
        __index = class
    }
    return setmetatable(instance, metatable)
end

function class:get_transform()
    return love.math.newTransform():translate(self.x, self.y)
end

function class:center(position)
    assert(position)
    self.x = math.floor(
        (love.graphics.getWidth() - tileset.tile_width * self.scale) / 2
        - position.x * tileset.tile_width * self.scale
    )
    self.y = math.floor(
        (love.graphics.getHeight() - tileset.tile_height * self.scale) / 2
        - position.y * tileset.tile_width * self.scale
    )
end

return class
