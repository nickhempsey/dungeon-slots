local clickSound = love.audio.newSource("assets/audio/button-click.wav", 'static')

local Button = {}
Button.__index = Button

function Button:new(label, x, y, callback, width, height, bg, hoverBg, color, hoverColor)
  local btn      = setmetatable({}, Button)
  btn.x          = x
  btn.y          = y
  btn.width      = width or 200
  btn.height     = height or 60
  btn.label      = label
  btn.callback   = callback or function() end
  btn.hover      = false
  btn.color      = color or Colors.text
  btn.bg         = bg or Colors.secondary
  btn.hoverColor = hoverColor or Colors.text
  btn.hoverBg    = hoverBg or Colors.accent
  return btn
end

function Button:isInside(mx, my)
  return mx >= self.x and mx <= self.x + self.width and
      my >= self.y and my <= self.y + self.height
end

function Button:update(dt)
  local mx, my = love.mouse.getPosition()
  self.hover = self:isInside(mx, my)

  function love.mousepressed(x, y, buttonPressed)
    self:mousepressed(x, y, buttonPressed)
  end
end

function Button:draw()
  -- Background
  if self.hover then
    love.graphics.setColor(unpack(self.hoverBg)) -- hover color
  else
    love.graphics.setColor(unpack(self.bg))      -- default color
  end
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10, 10)

  -- Label
  if self.hover then
    love.graphics.setColor(unpack(self.hoverColor)) -- hover color
  else
    love.graphics.setColor(unpack(self.color))      -- default color
  end

  love.graphics.setFont(Fonts.sm)
  love.graphics.printf(self.label, self.x, self.y + self.height / 2 - 10, self.width, "center")
end

function Button:mousepressed(mx, my, button)
  if button == 1 and self:isInside(mx, my) then
    clickSound:stop()
    clickSound:play()
    self.callback()
  end
end

return Button
