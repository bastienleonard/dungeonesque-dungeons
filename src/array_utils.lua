local module = {}

function module.map(f, array)
    assert(f)
    assert(array)
    local result = {}

    for _, item in ipairs(array) do
        table.insert(result, f(item))
    end

    return result
end

function module.contains(array, value)
    for _, item in ipairs(array) do
        if item == value then
            return true
        end
    end

    return false
end

function module.remove(array, value)
    local index = nil
    local found_item = nil

    for i, item in ipairs(array) do
        if item == value then
            index = i
            found_item = item
            break
        end
    end

    assert(index, string.format('Failed to remove %s in array', value))
    table.remove(array, index)
    return found_item
end

return module
