-- viewport.lua
local ViewportManager = {
  virtualWidth = 640,
  virtualHeight = 360,
  scale = 1,
  offsetX = 0,
  offsetY = 0,
  canvas = nil
}

-------------------------------------
---              LOAD             ---
-------------------------------------
function ViewportManager:load()
  self.canvas = love.graphics.newCanvas(self.virtualWidth, self.virtualHeight)
  self.canvas:setFilter("nearest", "nearest")
end

-------------------------------------
---          UPDATERS             ---
-------------------------------------
function ViewportManager:update()
  local winW, winH = love.graphics.getDimensions()
  self.scale = math.floor(math.min(winW / self.virtualWidth, winH / self.virtualHeight))
  self.offsetX = math.floor((winW - self.virtualWidth * self.scale) / 2)
  self.offsetY = math.floor((winH - self.virtualHeight * self.scale) / 2)
  love.graphics.setDefaultFilter("nearest", "nearest")
end

function ViewportManager:apply()
  love.graphics.translate(self.offsetX, self.offsetY)
  love.graphics.scale(self.scale)
  love.graphics.setDefaultFilter("nearest", "nearest")
end

function ViewportManager:clearCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(1, 1, 1, 1)
end

function ViewportManager:scaleCanvas()
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.push()
  ViewportManager:apply()
  love.graphics.draw(self.canvas, 0, 0)
  love.graphics.pop()
end

-------------------------------------
---            GETTERS            ---
-------------------------------------
function ViewportManager:getMousePosition()
  local mx, my = love.mouse.getPosition()
  return (mx - self.offsetX) / self.scale, (my - self.offsetY) / self.scale
end

function ViewportManager:getWidth()
  return self.virtualWidth
end

function ViewportManager:getHeight()
  return self.virtualHeight
end

function ViewportManager:getDimensions()
  return self.virtualWidth, self.virtualHeight
end

function ViewportManager:getScale()
  return self.scale
end

function ViewportManager:getOffset()
  return self.offsetX, self.offsetY
end

function ViewportManager:getMidScreen()
  local midScreen = {
    x = self:getWidth() / 2,
    y = self:getHeight() / 2
  }

  return midScreen
end

return ViewportManager
