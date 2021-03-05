local enum = require('./enum')

local module = {}
module.MoveDirection = enum('LEFT', 'RIGHT', 'UP', 'DOWN')

function module.new_move(unit, direction)
    assert(unit)
    assert(direction)
    error('TODO')
end

function module.new_attack(attacker, victim)
    assert(attacker)
    assert(victim)
    error('TODO')
end

return module
