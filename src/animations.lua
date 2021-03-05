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

local class = require('class')
local enum = require('enum')

local AnimationState = enum('UNSTARTED', 'RUNNING', 'ENDED')

local function create_animation(
        start_value,
        end_value,
        duration,
        callback,
        options)
    local animation = {}
    animation.state = AnimationState.UNSTARTED
    animation.start_value = start_value
    animation.end_value = end_value
    animation.duration = duration
    animation.ticks = 0
    animation.callback = callback
    animation.on_animation_start = options.on_animation_start
        or function() end
    animation.on_animation_end = options.on_animation_end
        or function() end
    animation.time_transformation = options.time_transformation
    return animation
end

local function update_animation(animation, dt)
    assert(animation)
    assert(dt)
    animation.ticks = animation.ticks + dt
    local time = animation.ticks / animation.duration

    if time >= 1 then
        animation.value = animation.end_value
        return true
    end

    if animation.time_transformation then
        time = animation.time_transformation(time)

        if time < 0 then
            time = 0
        elseif time > 1 then
            time = 1
        end
    end

    if time < 1 then
        local value = time
            * (animation.end_value - animation.start_value)
            + animation.start_value
        animation.value = value
    else
        animation.value = animation.end_value
        return true
    end

    return false
end

return class(
    'Animations',
    {
        _init = function(self)
            self._animations = {}
        end,

        update = function(self, dt)
            for id, animation in pairs(self._animations) do
                local ended = update_animation(animation, dt)

                if ended then
                    assert(animation.state ~= AnimationState.ENDED)
                    animation.state = AnimationState.ENDED
                end
            end
        end,

        draw = function(self)
            local ids_to_delete = {}

            for id, animation in pairs(self._animations) do
                if animation.state == AnimationState.UNSTARTED then
                    animation.on_animation_start()
                    animation.state = AnimationState.RUNNING
                end

                if animation.state == AnimationState.ENDED then
                    table.insert(ids_to_delete, id)
                    animation.callback(animation.end_value)
                    animation.on_animation_end()
                elseif animation.state == AnimationState.RUNNING then
                    animation.callback(animation.value)
                else
                    error(
                        string.format(
                            'Unhandled animation state %s',
                            animation.state
                        )
                    )
                end
            end

            for _, id in ipairs(ids_to_delete) do
                self._animations[id] = nil
            end
        end,

        animate = function(
                self,
                id,
                start_value,
                end_value,
                duration,
                callback,
                options)
            assert(id)
            assert(start_value)
            assert(end_value)
            assert(start_value ~= end_value)
            assert(duration)
            assert(callback)
            options = options or {}
            self._animations[id] = create_animation(
                start_value,
                end_value,
                duration,
                callback,
                options
            )
        end
    }
)
