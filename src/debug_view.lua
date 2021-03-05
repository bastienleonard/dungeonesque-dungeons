local array_utils = require('./array_utils')

local class = {}

local tile_info_font = love.graphics.newFont(40)

local function get_tile_info()
    local function get_unit_info(tile)
        if not tile then
            return
        end

        local unit_info

        if tile.unit then
            local unit = tile.unit
            local kind

            if unit.is_hero then
                kind = 'hero'
            else
                kind = 'enemy'
            end

            local hp = string.format(
                '%s/%s',
                unit.health.current_hp,
                unit.health.max_hp
            )
            unit_info = string.format('Unit : %s %s', kind, hp)
        else
            unit_info = 'Unit: none'
        end

        return unit_info
    end

    local function get_item_info(tile)
        if not tile then
            return
        end

        return string.format(
            'Item: %s',
            tile.item
        )
    end

    local function get_enemies_info()
        return string.format(
            '%s enemies left',
            #enemies
        )
    end

    local x, y = love.mouse.getPosition()
    x, y = camera:get_transform():inverseTransformPoint(x, y)
    x = math.floor(x / tileset.tile_width / camera.scale)
    y = math.floor(y / tileset.tile_height / camera.scale)
    local tile = map:get_tile_or_nil(x, y)
    local unit_info = get_unit_info(tile)
    local item_info = get_item_info(tile)
    local enemies_info = get_enemies_info()
    return string.format(
        '(%s,%s)\n%s\n%s\n%s',
        x,
        y,
        unit_info,
        item_info,
        enemies_info
    )
end

local function get_hero_info()
    local function get_hp_info()
        return string.format(
            'HP: %s/%s',
            hero.health.current_hp,
            hero.health.max_hp
        )
    end

    local function get_inventory_info()
        local items = table.concat(
            array_utils.map(
                function(item)
                    return tostring(item)
                end,
                hero.inventory.items
            ),
            ', '
        )
        return string.format('Inventory: %s', items)
    end

    local hp_info = get_hp_info()
    local inventory_info = get_inventory_info()
    return string.format('%s\n%s', hp_info, inventory_info)
end

function class.new()
    local instance = {}
    local metatable = {
        __index = class
    }
    return setmetatable(instance, metatable)
end

function class:draw()
    local text = string.format(
        '%s\n%s\n%s',
        string.format('%s FPS', love.timer.getFPS()),
        get_tile_info(),
        get_hero_info()
    )
    love.graphics.print(text, tile_info_font)
end

return class
