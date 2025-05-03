-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current
scene.playerReel = nil
scene.enemyReel = nil
scene.currentReel = nil
scene.enemyReelAnimations = {}
scene.playerReelAnimations = {}

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
    GameState.hero:setAnimation('idle')
    GameState.reel:spin()
    scene.enemyReel = GameState.reel:getResults()
    for i, v in ipairs(scene.enemyReel) do
      scene.enemyReelAnimations[i] = {
        id = v.id,
        sprite = v.assets.images.sprite.animations.factory('flash'),
        x = 900 + (i * 100),
        y = 310,
      }
    end

    for i, v in ipairs(scene.playerReelAnimations) do
      local curSymbol = GameState.hero:getSymbolById(v.id)
      -- LogManager.info(curSymbol)
      if curSymbol then
        scene.playerReelAnimations[i].sprite = curSymbol.assets.images.sprite.animations.factory('idle')
      end
    end
  end)
  EnemyButton:size('lg')
  EnemyButton:set('width', 300)
  EnemyButton:set('keybind', 'e')

  HeroButton = Button:new('Hero Roll', 600, 250, function()
    GameState.hero:setAnimation('spinning')
    GameState.reel:spin()
    scene.playerReel = GameState.reel:getResults()

    for i, v in ipairs(scene.playerReel) do
      scene.playerReelAnimations[i] = {
        id = v.id,
        sprite = v.assets.images.sprite.animations.factory('flash'),
        x = 500 + (i * 100),
        y = 310,
      }
    end

    for i, v in ipairs(scene.enemyReelAnimations) do
      local curSymbol = GameState.hero:getSymbolById(v.id)
      -- LogManager.info(curSymbol)
      if curSymbol then
        scene.enemyReelAnimations[i].sprite = curSymbol.assets.images.sprite.animations.factory('idle')
      end
    end
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

  for _, v in ipairs(scene.playerReelAnimations) do
    v.sprite:update(dt)
  end
  for _, v in ipairs(scene.enemyReelAnimations) do
    v.sprite:update(dt)
  end
end

-- Scene draw loop
function scene.draw()
  HeroButton:draw()
  EnemyButton:draw()
  GameState:draw()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Fonts.xl)
  love.graphics.printf("\"Combat Scene\"", 0, 150, love.graphics.getWidth(), "center")

  if scene.playerReelAnimations ~= nil then
    for _, v in pairs(scene.playerReelAnimations) do
      v.sprite:draw(v.x, v.y)
    end
  end
  if scene.enemyReelAnimations ~= nil then
    for _, v in pairs(scene.enemyReelAnimations) do
      v.sprite:draw(v.x, v.y)
    end
  end
end

return scene
