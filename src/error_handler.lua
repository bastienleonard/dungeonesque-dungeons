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

-- Adapted from https://github.com/love2d/love/blob/master/src/scripts/boot.lua

local utf8 = require('utf8')

local module = {}

local function error_printer(message, layer)
    print(
        debug.traceback(
            "Error: " .. tostring(message), 1 + (layer or 1)
        ):gsub("\n[^\n]+$", "")
    )
end

function module.handle(message)
    assert(message)
    message = tostring(message)

    error_printer(message, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)

        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end

    if love.joystick then
        -- Stop all joystick vibrations.
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end

    if love.audio then
        love.audio.stop()
    end

    love.graphics.reset()

    -- TODO: scale font based on display density
    love.graphics.setNewFont(14 * 4)

    love.graphics.setColor(1, 1, 1)
    local trace = debug.traceback()
    love.graphics.origin()
    local sanitized_message = {}

    for char in message:gmatch(utf8.charpattern) do
        table.insert(sanitized_message, char)
    end

    sanitized_message = table.concat(sanitized_message)
    local err = {}
    table.insert(err, "Error\n")
    table.insert(err, sanitized_message)

    if #sanitized_message ~= #message then
        table.insert(err, "Invalid UTF-8 string in error message.")
    end

    table.insert(err, "\n")

    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = p:gsub("\t", "")
    p = p:gsub("%[string \"(.-)\"%]", "%1")

    local function draw()
        local pos = 70
        love.graphics.clear(89/255, 157/255, 220/255)
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        love.graphics.present()
    end

    local fullErrorText = p
    local function copyToClipboard()
        if not love.system then return end
        love.system.setClipboardText(fullErrorText)
        p = p .. "\nCopied to clipboard!"
        draw()
    end

    if love.system then
        p = p .. "\n\nPress Ctrl+C or tap to copy this error"
    end

    return function()
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "escape" then
                return 1
            elseif e == "keypressed"
                and a == "c"
                and love.keyboard.isDown("lctrl", "rctrl") then
                copyToClipboard()
            elseif e == "touchpressed" then
                local name = love.window.getTitle()

                if #name == 0 or name == "Untitled" then
                    name = "Game"
                end

                local buttons = {"OK", "Cancel"}

                if love.system then
                    buttons[3] = "Copy to clipboard"
                end

                local pressed = love.window.showMessageBox(
                    "Quit "..name.."?", "", buttons
                )

                if pressed == 1 then
                    return 1
                elseif pressed == 3 then
                    copyToClipboard()
                end
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end

return module
