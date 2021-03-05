local Camera = require('./camera')
local DebugView = require('./debug_view')
local DefaultEventHandler = require('./default_event_handler')
local error_handler = require('./error_handler')
local EventHandlersStack = require('./event_handlers_stack')
local game_logic = require('./game_logic')
local random = require('./random')
local rendering = require('./rendering')
local Unit = require('./unit')
local utils = require('./utils')

function love.load()
    event_handlers_stack = EventHandlersStack.new()
    game_logic.push_event_handler(DefaultEventHandler.new())
    FOV_ENABLED = true
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
    tileset = {
        image = love.graphics.newImage('assets/Tilesheet/colored_packed.png'),
        tile_width = 16,
        tile_height = 16
    }
    camera = Camera.new()
    hero = Unit.new_hero()
    game_logic.enter_new_level(hero)
    debug_view = DebugView.new()
end

function love.update(dt)
end

function love.draw()
    love.graphics.applyTransform(camera:get_transform())
    utils.with_saved_color(
        function()
            for x, y, tile in map:iter() do
                rendering.draw_tile(x, y, tile)
            end
        end
    )
    love.graphics.origin()
    debug_view:draw()
end

function love.keypressed(key, scancode, is_repeat)
    event_handlers_stack:current():on_key_pressed(
        key,
        scancode,
        is_repeat,
        function()
            event_handlers_stack:pop()
        end
    )
end

function love.errorhandler(message)
    return error_handler.handle(message)
end
