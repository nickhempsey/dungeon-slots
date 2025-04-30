-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current
scene.currentReel = nil

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
  HeroButton = Button:new('Roll Hero Reel', 600, 250, function()
    GameState.reel:spin()
    scene.currentReel = GameState.reel:getResults()
    -- GameState.hero:applyDamage(10)
    LogManager.info(scene.currentReel)
  end)
  HeroButton:size('lg')
  HeroButton:set('width', 300)
  HeroButton:set('keybind', 'r')
end

-- Scene updates loop
function scene.update(dt)
  HeroButton:update(dt)
  -- LogManager.info(GameState.hero.stats.health)
end

-- Scene draw loop
function scene.draw()
  HeroButton:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Combat Scene", 600, 600)

  if scene.currentReel ~= nil then
    for i, v in ipairs(scene.currentReel) do
      local path = 'config/symbols/' .. v.id .. '/' .. v.assets.sprite
      local sprite = love.graphics.newImage(path)
      love.graphics.draw(sprite, 500 + (i * 100), 310, 0, 0.1, 0.1)
    end
  end
end

return scene
