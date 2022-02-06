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

local array_utils = require('array_utils')
local colors = require('colors')

local module = {}

function module.is_integer(n)
    return math.floor(n) == n
end

function module.round(n)
    return math.floor(n + 0.5)
end

function module.is_power_of_two(n)
    assert(n)
    return module.is_integer(math.log(n, 2))
end

function module.distance(a, b)
    assert(a)
    assert(b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
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
                    args,
                    function(attr)
                        return string.format(
                            '%s=%s',
                            attr,
                            self[attr]
                        )
                    end
                ),
                ' '
            )
        )
    end
end

function module.print_with_shadow(text, font, x, y, text_color, shadow_color)
    assert(text)
    assert(font)
    assert(x)
    assert(y)
    text_color = text_color or colors.WHITE
    shadow_color = shadow_color or colors.BLACK
    local offset = 1
    love.graphics.setColor(unpack(shadow_color))
    love.graphics.print(text, font, x + offset, y + offset)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(text, font, x, y)
end

return module
