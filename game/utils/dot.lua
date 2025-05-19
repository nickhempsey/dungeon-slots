-- drill into nested tables by "a.b.c" path
local function dot(tbl, path)
    for part in path:gmatch("[^.]+") do
        if not tbl then return nil end
        tbl = tbl[part]
    end
    return tbl
end

return dot
