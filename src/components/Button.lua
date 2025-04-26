local clickSound = love.audio.newSource("assets/audio/button-click.wav", 'static')


local Button = {}
Button.__index = Button

-- Creates a new button
---@param label string
---@param x number
---@param y number
---@param callback function
---@return table
function Button:new(label, x, y, callback)
  -- Avaliable sizes
  local btnSizes   = {}
  btnSizes.sm      = { width = 75, height = 30, fontSize = Fonts.sm, fontOffset = 8 }
  btnSizes.md      = { width = 100, height = 40, fontSize = Fonts.md, fontOffset = 10 }
  btnSizes.lg      = { width = 150, height = 60, fontSize = Fonts.lg, fontOffset = 15 }

  -- Properties
  local btn        = setmetatable({}, Button)
  btn.label        = label
  btn.x            = x
  btn.y            = y
  btn.callback     = callback or function() end
  btn.width        = btnSizes.sm.width
  btn.height       = btnSizes.sm.height
  btn.fontOffset   = btnSizes.sm.fontOffset
  btn.fontSize     = btnSizes.sm.fontSize
  btn.hover        = false
  btn.color        = Colors.text
  btn.bg           = Colors.secondary
  btn.hoverColor   = Colors.text
  btn.hoverBg      = Colors.accent
  btn.borderRadius = 4
  btn.mouseKey     = 1
  btn.keyboardKey  = nil
  btn.sound        = clickSound
  btn.btnSizes     = btnSizes
  return btn
end

function Button:size(size)
  print(size)
  self.width      = self.btnSizes[size].width
  self.height     = self.btnSizes[size].height
  self.fontOffset = self.btnSizes[size].fontOffset
  self.fontSize   = self.btnSizes[size].fontSize
  return self
end

function Button:set(key, value)
  self[key] = value
  return self
end

-- Checks to if your mouse is inside of the button.
---@param mx number
---@param my number
---@return boolean
function Button:isInside(mx, my)
  return mx >= self.x and mx <= self.x + self.width and
      my >= self.y and my <= self.y + self.height
end

-- Set inside love.update
---@param dt number
function Button:update(dt)
  local mx, my = love.mouse.getPosition()
  self.hover = self:isInside(mx, my)

  if self.keyboardkey ~= nil and love.keyboard.isPressed(self.keyboardKey) then
    self:playsound()
    self.callback()
  end

  if self.mouseKey ~= nil and love.mouse.isPressed(self.mouseKey) and self.hover then
    self:playsound()
    self.callback()
  end
end

function Button:playsound()
  if self.sound then
    self.sound:stop()
    self.sound:play()
  end
end

-- Draw the button to the screen
function Button:draw()
  -- Background
  if self.hover then
    love.graphics.setColor(self.hoverBg) -- hover color
  else
    love.graphics.setColor(self.bg)      -- default color
  end
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.borderRadius, self.borderRadius)

  -- Label
  if self.hover then
    love.graphics.setColor(self.hoverColor) -- hover color
  else
    love.graphics.setColor(self.color)      -- default color
  end

  love.graphics.setFont(self.fontSize)
  love.graphics.printf(self.label, self.x, self.y + self.height / 2 - self.fontOffset, self.width, "center")
end

return Button
