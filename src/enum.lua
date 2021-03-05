return function(...)
    local names = { ... }
    local enum = {}

    for _, name in ipairs(names) do
        enum[name] = setmetatable(
            {},
            { __tostring = function(self) return name end }
        )
    end

    return enum
end
