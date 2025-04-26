local Fonts = {}
Fonts.__index = Fonts

Fonts.xxl = love.graphics.newFont(100)
Fonts.xl = love.graphics.newFont(80)
Fonts.lg = love.graphics.newFont(60)
Fonts.md = love.graphics.newFont(40)
Fonts.sm = love.graphics.newFont(20)

return Fonts
