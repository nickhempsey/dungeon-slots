-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current

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
  playerButton = Button:new('Roll Player Reel', 150, 250, function()
    GameState.reel:spin()
    GameState.reel:getResults()
    LogManager.error(GameState.reel:getResults())
    LogManager.warn(GameState.reel:getResults())
    LogManager.info(GameState.reel:getResults())
    LogManager.debug(GameState.reel:getResults())
  end)
  playerButton:size('lg')
  playerButton:set('width', 300)
end

-- Scene updates loop
function scene.update(dt)
  playerButton:update(dt)
end

-- Scene draw loop
function scene.draw()
  playerButton:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Combat Scene", 600, 600)
end

return scene
