local module = {}

function module.choice(array)
    assert(array)

    if #array == 0 then
        error("Can't pick random item from empty array")
    end

    local index = love.math.random(1, #array)
    return array[index]
end

function module.shuffle(array)
    assert(array)

    if #array > 1 then
        for i = 1, #array - 1 do
            local index = love.math.random(i, #array)
            array[i], array[index] = array[index], array[i]
        end
    end
end

return module
