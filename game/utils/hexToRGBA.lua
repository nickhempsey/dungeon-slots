local function hexToRGBA(hex, alpha)
    -- Remove '#' if present
    hex = hex:gsub("#", "")
    -- Handle short form like 'FA0'
    if #hex == 3 then
        hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
    end
    -- Parse the hex string
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = alpha or 1
    return { r, g, b, a }
end

-- Example usage:
-- local rgb = hexToRGBA("#FFAA00")
-- print(rgb[1], rgb[2], rgb[3], rgba[4]) -- Output: 1.0 0.66666666666667 0.0
return hexToRGBA
