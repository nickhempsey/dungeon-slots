local Lair = require "src.entities.Lair"

-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current

scene.playerReel = nil
scene.currentReel = nil
scene.playerReelAnimations = {}

scene.current_turn = nil
scene.entity_references = {}
scene.lair = nil

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
  lair = Lair:new('tutorial_lair')

  if lair then
    LogManager.info(lair)
    lair:generateEnemies()
  end

  scene.playerReel = Reel:new(GameState.hero:getBaseSymbols())

  -- LogManager.info(scene.playerReel)
  -- HeroButton = Button:new('Hero', 100, 100, function()
  --   scene.playerReel:spin()

  --   LogManager.info(scene.playerReel:getResults())

  --   for _, symbol in pairs(scene.playerReel:getResults()) do
  --     local isCrit = symbol:roll('crit')
  --     local baseDamage = symbol:roll('damage')
  --     local totalDamage = baseDamage
  --     if isCrit then
  --       totalDamage = baseDamage * 1.3
  --     end

  --     LogManager.info(string.format("Symbols: %s crit: %s basedmg: %d total: %f", symbol.name, isCrit, baseDamage,
  --       totalDamage))
  --   end
  -- end)
  -- HeroButton:size('md')
  -- HeroButton:modify({
  --   keybind = 'r',
  --   bg = Colors.primary,
  --   hoverBg = Colors.secondary,
  --   color = Colors.background,
  --   hoverColor = Colors.text
  -- })
end

-- Scene updates loop
function scene.update(dt)
  -- HeroButton:update(dt)
  -- GameState.lair:update(dt)
  GameState.hero:update(dt)
  if lair and lair.generatedEnemies then
    for _, v in pairs(lair.generatedEnemies) do
      v:update(dt)
    end
  end
end

-- Scene draw loop
function scene.draw()
  GameState:draw()
  -- GameState.lair:draw()
  GameState.hero:draw()
  -- HeroButton:draw()
  if lair and lair.generatedEnemies then
    for _, v in pairs(lair.generatedEnemies) do
      v:draw()
    end
  end
end

return scene
