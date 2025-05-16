local hexToRGBA = require "utils.hexToRGBA"

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
  btnSizes.sm      = { width = 80, height = 16 }
  btnSizes.md      = { width = 96, height = 20 }
  btnSizes.lg      = { width = 108, height = 24 }

  -- Properties
  local btn        = setmetatable({}, Button)
  btn.label        = label
  btn.x            = x
  btn.y            = y
  btn.callback     = callback or function() end
  btn.width        = btnSizes.sm.width
  btn.height       = btnSizes.sm.height
  btn.fontSize     = 'sm'
  btn.font         = 'PressStart'

  btn.hover        = false
  btn.color        = hexToRGBA('#000000')
  btn.bg           = hexToRGBA('#FF004D')
  btn.hoverColor   = hexToRGBA('#ffffff')
  btn.hoverBg      = hexToRGBA('#7E2553')
  btn.borderRadius = 4
  btn.mousebind    = 1
  btn.keybind      = nil
  btn.sound        = love.audio.newSource("assets/audio/button-click.wav", 'static')
  btn.btnSizes     = btnSizes
  return btn
end

-- Allows you to set the size of a button using the predefined button sizes.
---@param sizeName string sm | md | lg
function Button:size(sizeName)
  if self.btnSizes[sizeName] == nil then
    return self
  end

  self.width    = self.btnSizes[sizeName].width
  self.height   = self.btnSizes[sizeName].height
  self.fontSize = sizeName
  return self
end

function Button:modify(flags)
  assert(type(flags) == "table", "Function 'modify': parameter 'flags' must be a table.")
  for k, v in pairs(flags) do
    self[k] = v
  end
end

function Button:set(key, value)
  self[key] = value
  return self
end

--- Checks if the mouse is inside of the button... duh
---
---@param mx number
---@param my number
---@return boolean
function Button:isInside(mx, my)
  return mx >= self.x and mx <= self.x + self.width and
      my >= self.y and my <= self.y + self.height
end

--- Set inside love.update
---
---@param dt number
function Button:update(dt)
  local mx, my = ViewportManager:getMousePosition()
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

--- Play sound on click
--- TODO: Add a global setting that sets volumes for things like buttons, or ui.
function Button:playsound()
  if self.sound then
    self.sound:stop()
    self.sound:play()
  end
end

--- Draw the button to the screen
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

  FontsManager:setFont(self.fontSize, self.font)

  --- This is how we position the text in the center of the button
  --- I miss CSS. :(
  local fontSize = FontsManager.sizes[self.fontSize]
  local posYOffset = (self.y - fontSize)
  local oy = (fontSize + (self.height - fontSize) / 2) * -1
  love.graphics.printf(
    self.label,
    math.floor(self.x),
    math.floor(posYOffset), -- To the top of the button
    math.floor(self.width),
    "center",
    nil,
    nil,
    nil,
    nil,
    math.floor(oy) -- Push it into center with y offset
  )
end

return Button
