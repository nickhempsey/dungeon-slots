local cur = SceneManager.current
local scene = {}
scene.zsort = 100

local background = love.graphics.newImage("assets/images/placeholder_bg.jpg")

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
  local midScreen = ViewportManager:getMidScreen()
  startButton = Button:new('Start Game', midScreen.x, midScreen.y, function()
    SceneManager.add('combat')
    SceneManager.purge('intro')
  end)
  startButton:size('md')
  startButton:set('x', midScreen.x - startButton.width / 2)
  startButton:set('y', midScreen.y - startButton.height / 2)
  -- startButton:set('width', 300)
end

-- Scene updates loop
function scene.update(dt)
  startButton:update(dt)
end

-- Scene draw loop
function scene.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(background, 0, 0)

  startButton:draw()
end

return scene
