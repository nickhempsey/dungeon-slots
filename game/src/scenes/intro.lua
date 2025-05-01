local cur = SceneManager.current
local scene = {}
scene.zsort = 100

local background = love.graphics.newImage("assets/images/random_bg.jpg")

-- Stacking Scene Manager can be used to call a scenes modify function.
-- The modify function is intended to be used for changing specific
-- parts of a scene defined in the flags table. Each scene can have a
-- unique modify function that handles received flags respectively.
--
-- The modify function is not intended to restart a scene, to do this
-- first purge then add the scene again.
function scene.modify(flags)
end

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  local midScreen = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2
  }
  startButton = Button:new('Start Game', love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, function()
    SceneManager.add('combat')
    SceneManager.purge('intro')
  end)

  startButton:size('lg')
  startButton:set('width', 300)
  startButton:set('x', midScreen.x - startButton.width / 2)
  startButton:set('y', midScreen.y - startButton.height / 2)
end

-- Scene updates loop
function scene.update(dt)
  startButton:update(dt)
end

-- Scene draw loop
function scene.draw()
  local windowWidth, windowHeight = love.graphics.getDimensions()
  local bgWidth = background:getWidth()
  local bgHeight = background:getHeight()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(background, 0, 0, 0,
    windowWidth / bgWidth,
    windowHeight / bgHeight)

  startButton:draw()
end

return scene
