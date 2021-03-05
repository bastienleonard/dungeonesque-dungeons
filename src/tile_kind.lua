local enum = {}

for name, attributes in pairs({
        NOTHING = {
            walkable = true,
            blocks_sight = false
        },
        WALL = {
            walkable = false,
            blocks_sight = true
        },
        STAIRS = {
            walkable = true,
            blocks_sight = false
        },
        BOOKSHELF = {
            walkable = false,
            blocks_sight = true
        }
}) do
    enum[name] = setmetatable(
        attributes,
        { __tostring = function() return name end }
    )
end

return enum
