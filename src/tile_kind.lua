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
        },
        BOOKSHELF_WITH_SKULL = {
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
