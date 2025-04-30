-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current
scene.playerReel = nil
scene.enemyReel = nil
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
  EnemyButton = Button:new('Enemy Roll', 1000, 250, function()
    GameState.reel:spin()
    scene.enemyReel = GameState.reel:getResults()
  end)
  EnemyButton:size('lg')
  EnemyButton:set('width', 300)
  EnemyButton:set('keybind', 'e')

  HeroButton = Button:new('Hero Roll', 600, 250, function()
    GameState.reel:spin()
    scene.playerReel = GameState.reel:getResults()
    -- GameState.hero:applyDamage(10)
    -- LogManager.info(scene.currentReel)
  end)
  HeroButton:size('lg')
  HeroButton:set('width', 300)
  HeroButton:set('keybind', 'r')
  HeroButton:set('bg', Colors.primary)
  HeroButton:set('hoverBg', Colors.secondary)
  HeroButton:set('color', Colors.background)
  HeroButton:set('hoverColor', Colors.text)
end

-- Scene updates loop
function scene.update(dt)
  HeroButton:update(dt)
  EnemyButton:update(dt)
  -- LogManager.info(GameState.hero.stats.health)
end

-- Scene draw loop
function scene.draw()
  HeroButton:draw()
  EnemyButton:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Fonts.xl)
  love.graphics.printf("\"Combat Scene\"", 0, 150, love.graphics.getWidth(), "center")

  if scene.playerReel ~= nil then
    for i, v in ipairs(scene.playerReel) do
      love.graphics.draw(v.assets.images.sprite, 500 + (i * 100), 310, 0, 0.1, 0.1)
    end
  end
  if scene.enemyReel ~= nil then
    for i, v in ipairs(scene.enemyReel) do
      love.graphics.draw(v.assets.images.sprite, 900 + (i * 100), 310, 0, 0.1, 0.1)
    end
  end
end

return scene
