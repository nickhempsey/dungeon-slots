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
  EnemyButton = Button:new('Enemy Roll', 400, 100, function()
    GameState.hero:setAnimation('idle')
    GameState.reel:spin()
    scene.enemyReel = GameState.reel:getResults()
    for i, v in ipairs(scene.enemyReel) do
      local sprite = v.assets.images.sprite.animations.factory('flash')
      scene.enemyReelAnimations[i] = {
        id = v.id,
        sprite = sprite,
        x = EnemyButton.x - sprite:getWidth() * 1.5 + (i * sprite:getWidth()),
        y = EnemyButton.y + EnemyButton.height,
      }
    end

    for _, v in pairs(scene.playerReelAnimations) do
      v.sprite:setTag('idle')
    end
  end)
  EnemyButton:size('md')
  EnemyButton:set('keybind', 'e')

  HeroButton = Button:new('Hero Roll', 100, 100, function()
    GameState.hero:setAnimation('spinning')
    GameState.reel:spin()
    scene.playerReel = GameState.reel:getResults()
    for i, v in ipairs(scene.playerReel) do
      local sprite = v.assets.images.sprite.animations.factory('flash')
      scene.playerReelAnimations[i] = {
        id = v.id,
        sprite = sprite,
        x = HeroButton.x - sprite:getWidth() * 1.5 + (i * sprite:getWidth()),
        y = HeroButton.y + HeroButton.height,
      }
    end

    for _, v in pairs(scene.enemyReelAnimations) do
      v.sprite:setTag('idle')
    end
  end)
  HeroButton:size('md')
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
  GameState.hero:update(dt)

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
  GameState.hero:draw()


  love.graphics.setColor(1, 1, 1, 1)
  FontsManager:setFont('xl')
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
