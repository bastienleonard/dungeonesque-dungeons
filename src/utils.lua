local array_utils = require('./array_utils')

local module = {}

function module.round(n)
    return math.floor(n + 0.5)
end

function module.with_saved_color(f)
    assert(f)
    local previousColor = { love.graphics.getColor() }
    f()
    love.graphics.setColor(unpack(previousColor))
end

function module.require_not_nil(x, name)
    if x == nil then
        if name == nil then
            name = '[unspecified]'
        end

        error(string.format('%s cannot be nil', name))
    end

    return x
end

function module.make_to_string(class_name, ...)
    assert(class_name)
    local args = { ... }
    return function(self)
        return string.format(
            '%s<%s>',
            class_name,
            table.concat(
                array_utils.map(
                    function(attr)
                        return string.format(
                            '%s=%s',
                            attr,
                            self[attr]
                        )
                    end,
                    args
                ),
                ', '
            )
        )
    end
end

return module
