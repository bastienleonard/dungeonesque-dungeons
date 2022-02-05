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

local module = {}

-- local FONT_NAME = 'assets/fonts/texturina/static/Texturina-Regular.ttf'
-- local FONT_NAME = 'assets/fonts/bitter/static/Bitter-Regular.ttf'
-- local FONT_NAME = 'assets/fonts/eczar/Eczar-Regular.ttf'
-- local FONT_NAME = 'assets/fonts/vesper/VesperLibre-Regular.ttf'
local FONT_NAME = 'assets/fonts/alegreya-sans/AlegreyaSans-Regular.ttf'
-- local FONT_NAME = 'assets/fonts/alegreya/static/Alegreya-Regular.ttf'
local fonts = {}

-- TODO: don't let the caller choose the size
function module.get(size)
    assert(size)
    local font = fonts[size]

    if font == nil then
        print(string.format('Loading font for size %s', size))
        local args = {}

        if FONT_NAME then
            table.insert(args, FONT_NAME)
        end

        table.insert(args, size)
        font = love.graphics.newFont(unpack(args))
        fonts[size] = font
    end

    return font
end

return module
