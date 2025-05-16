local function readonly(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function()
            error("Attempt to modify a read-only table")
        end,
        __metatable = false
    })
end

return readonly
