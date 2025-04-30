Button = {}
Button.__index = Button

Button.debug = Debug
Button.debugLabel = LogManagerColor.colorf('{green}[Button]{reset}')

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
  btn.mousebind    = 1
  btn.keybind      = nil
  btn.sound        = love.audio.newSource("assets/audio/button-click.wav", 'static')
  btn.btnSizes     = btnSizes
  return btn
end

-- Allows you to set the size of a button using the predefined button sizes.
---@param size string sm | md | lg
function Button:size(size)
  if self.btnSizes[size] == nil then
    return self
  end

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

-- Checks if the mouse is inside of the button... duh
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

  local keypressed = self.keybind ~= nil and love.keyboard.isPressed(self.keybind)
  local mousepressed = self.mousebind ~= nil and love.mouse.isPressed(self.mousebind) and self.hover

  if keypressed or mousepressed then
    if self.debug then
      local activationType = keypressed and "keybind" or "mousebind"
      local bindType = keypressed and self.keybind or self.mousebind
      LogManager.debug(string.format("%s '%s', activated using %s '%s'", Button.debugLabel, self.label, activationType,
        bindType))
    end

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
