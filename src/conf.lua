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

function love.conf(t)
    t.version = '11.3'
    t.window.fullscreen = true
    t.window.title = 'Dungeonesque dungeons'
    t.window.icon = 'assets/icon.png'
    t.window.resizable = true

    t.window.vsync = true

    t.modules.audio = false
    t.modules.data = false
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end
