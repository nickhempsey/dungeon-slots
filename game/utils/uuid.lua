local function random_hex(n)
    local s = ""
    for i = 1, n do
        s = s .. string.format("%x", love and love.math.random(0, 15) or math.random(0, 15))
    end
    return s
end

return function()
    return string.format(
        "%s%s-%s-%s-4%s-%s%s%s",
        random_hex(4), random_hex(4),
        random_hex(4),
        random_hex(3),
        random_hex(3):sub(2, 3),
        string.format("%x", (8 + (love and love.math.random(0, 3) or math.random(0, 3)))), -- variant 8,9,a,b
        random_hex(3),
        random_hex(6)
    )
end
