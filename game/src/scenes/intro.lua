local cur = SceneManager.current
local scene = {}
scene.zsort = 100

local background = love.graphics.newImage("assets/images/UI_Tests.png")

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
  startButton = Button:new('START', midScreen.x, midScreen.y, function()
    SceneManager.add('combat')
    SceneManager.purge('intro')
  end)
  startButton:size('md')
  startButton:set('x', midScreen.x - startButton.width / 2)
  startButton:set('y', midScreen.y - startButton.height / 2)
  startButton:set('font', 'Pixellari')
end

-- Scene updates loop
function scene.update(dt)
  startButton:update(dt)
  GameState:update(dt)
  GameState.hero:update(dt)
end

-- Scene draw loop
function scene.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(background, 0, 0)
  --  GameState:draw()
  -- GameState.hero:draw()

  --[[
  Finally understand why fonts are blurry.
  When scaling, fonts need be rendered in multiples of their base value or they wind up on subpixel positions and look blurry.
  If we're using image fonts need to be rendered at their actual pixel sizes, we can use graphics.scale but this has it's limitations.
  We would need to build out specific sized image fonts for smaller fonts specifically as I noticed scaling down is really bad.
  Will setup a task to find some 3 or 5 px image fonts.
  ]]
  -- love.graphics.setColor(1, 1, 1, 1)
  -- FontsManager:getLoadedBMP('FreePixelBMP')
  -- FontsManager:setFontBMP('xs') -- Does not work, will need to be handled via scaling or creating specific image sizes.
  -- love.graphics.push()
  -- love.graphics.scale(0.5, 0.5)
  -- love.graphics.printf('Deserunt qui quis nulla ipsum elit velit ut sit esse Lorem excepteur.', 10, 10, 400, "left")
  -- love.graphics.pop()

  startButton:draw()
end

return scene
