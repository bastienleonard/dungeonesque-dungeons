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

local function screen_size()
    local width, height, flags = love.window.getMode()

    if not flags.fullscreen then
        love.window.setFullscreen(true)
    end

    local fullscreen_width, fullscreen_height = love.window.getMode()

    if not flags.fullscreen then
        love.window.setMode(width, height, flags)
    end

    return fullscreen_width, fullscreen_height
end

local function guess_scale_factor()
    local width, height = screen_size()

    if height > width then
        width, height = height, width
    end

    local scale_factor

    if height <= 1080 then
        scale_factor = 1
    else
        scale_factor = height / 1080
    end

    print(
        string.format(
            'UI scale factor is %s (for a %sx%s screen)',
            scale_factor,
            width,
            height
        )
    )
    assert(scale_factor)
    return scale_factor
end

local scale_factor = guess_scale_factor()

return function(n)
    return n * scale_factor
end
