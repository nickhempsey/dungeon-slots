FontsManager = {}
FontsManager.__index = FontsManager

--- Default Font Sizes
FontsManager.sizes = {
  xxl = 48,
  xl = 40,
  lg = 32,
  md = 16,
  sm = 8,
  xs = 4
}
--- Default Font Lineheights that can be used for buttons and whatnot to automatically center the text
--- TODO: This isn't actually hooked up yet.
FontsManager.lineheight = {
  xxl = 28,
  xl = 24,
  lg = 20,
  md = 16,
  sm = 12
}

--- The fonts that the game will use.
--- TODO: Remove fonts from ManifestManager, let's just control all fonts in one place for now.
FontsManager.fonts = {
  PressStart = 'assets/fonts/PressStart2P-Regular.ttf',
  Pixellari = 'assets/fonts/Pixellari.ttf',
  FreePixel = 'assets/fonts/FreePixel.ttf',
}

FontsManager.bmpfonts = {
  FreePixelBMP = 'assets/fonts/pixelfree.png'
}

--- A cache for the loaded fonts that we'll be using.
FontsManager.cache = {}
FontsManager.bmpcache = {}

FontsManager.debug = Debug
FontsManager.debugLabel = LogManagerColor.colorf('{magenta}[FontsManager]{reset}')

--- Loads all fonts during love.load so that we have them ready to go.
function FontsManager:load()
  self.cache = {}

  for name, path in pairs(self.fonts) do
    self.cache[name] = {}

    for sizeName, px in pairs(self.sizes) do
      local font = love.graphics.newFont(path, px)
      font:setFilter("nearest", "nearest")
      self.cache[name][sizeName] = font
      if self.debug then
        LogManager.debug(string.format("%s Loaded font '%s' '%s'", self.debugLabel, name, sizeName))
      end
    end
  end
end

--- Allows for :setFont to grab the font from cache and load it if needed.
---
---@param fontName string
---@param sizeName string
---@return love.graphics.font | nil
function FontsManager:getLoaded(fontName, sizeName)
  assert(fontName, "'fontName' must be a string.")
  assert(sizeName, "'sizeName' must be a string.")
  local fontSet = self.cache[fontName]
  return fontSet and fontSet[sizeName] or nil
end

--- Sets the font requested by a draw method.
---
---@param sizeName string
---@param fontName string?
function FontsManager:setFont(sizeName, fontName)
  fontName = fontName or 'PressStart'
  sizeName = sizeName or 'sm'

  local font = self:getLoaded(fontName, sizeName)
  if font then
    love.graphics.setFont(font)
  else
    error("Font not loaded: " .. fontName .. "@" .. sizeName)
  end
end

function FontsManager:loadBMP()
  self.bmpcache = {}

  for name, path in pairs(self.bmpfonts) do
    self.bmpcache[name] = {}

    local font = love.graphics.newImageFont(
      path,
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#.!?: ",
      3)
    -- font:setFilter("nearest", "nearest")
    self.bmpcache[name] = font
    if self.debug then
      LogManager.debug(string.format("%s Loaded BMP font '%s'", self.debugLabel, name))
    end
  end
end

--- Allows for :setFont to grab the font from cache and load it if needed.
---
---@param fontName string
---@return love.graphics.font | nil
function FontsManager:getLoadedBMP(fontName)
  assert(fontName, "'fontName' must be a string.")
  -- assert(sizeName, "'sizeName' must be a string.")
  local fontSet = self.bmpcache[fontName]
  return fontSet
end

--- Sets the font requested by a draw method.
---
---@param sizeName string
---@param fontName string?
function FontsManager:setFontBMP(sizeName, fontName)
  fontName = fontName or 'FreePixelBMP'
  sizeName = sizeName or 'sm'

  local font = self:getLoadedBMP(fontName)
  if font then
    love.graphics.setFont(font)
  else
    error("Font not loaded: " .. fontName .. "@" .. sizeName)
  end
end

return FontsManager
