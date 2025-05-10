-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current

scene.playerReel = nil
scene.currentReel = nil
scene.playerReelAnimations = {}

scene.current_turn_index = nil
scene.entity_references = {}

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
  -- TODO: Move this to a procedural generation system based on the map configurations.
  GameState:generateEnemies(4, 'combat')
  scene.playerReel = Reel:new(GameState.hero:getBaseSymbols())

  LogManager.info(scene.playerReel)
  HeroButton = Button:new('Hero', 100, 100, function()
    scene.playerReel:spin()

    LogManager.info(scene.playerReel:getResults())

    for _, symbol in pairs(scene.playerReel:getResults()) do
      local isCrit = symbol:roll('crit')
      local baseDamage = symbol:roll('damage')
      local totalDamage = baseDamage
      if isCrit then
        totalDamage = baseDamage * 1.3
      end

      LogManager.info(string.format("Symbols: %s crit: %s basedmg: %d total: %f", symbol.name, isCrit, baseDamage,
        totalDamage))
    end
  end)
  HeroButton:size('md')
  HeroButton:modify({
    keybind = 'r',
    bg = Colors.primary,
    hoverBg = Colors.secondary,
    color = Colors.background,
    hoverColor = Colors.text
  })
end

-- Scene updates loop
function scene.update(dt)
  HeroButton:update(dt)
  GameState.hero:update(dt)

  for _, v in pairs(GameState.enemies) do
    v:update(dt)
  end
end

-- Scene draw loop
function scene.draw()
  HeroButton:draw()
  GameState:draw()
  GameState.hero:draw()

  for _, v in pairs(GameState.enemies) do
    v:draw()
  end
end

return scene
