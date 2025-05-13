local tableMerge = require "utils.tableMerge"
local Enemy = {}
Enemy.__index = Enemy

Enemy.debug = Debug
Enemy.debugLabel = LogManagerColor.colorf("{red}[Enemy]{reset}")

-- Instantiate a new hero by their id.
--
---@param id string
function Enemy:new(id)
  assert(type(id) == "string", "Function 'new': parameter 'id' must be a string.")
  LogManager.info(string.format("%s New enemy: %s", Enemy.debugLabel, id))

  local manifest = ManifestManager.loadEntityManifest("enemies", id)
  if not manifest then
    return nil
  end

  local entity = setmetatable(tableMerge.deepMergeWithArray({
    currentSprite = nil,
    currentAnimation = nil,
    x = 0,
    y = 0,
    ox = 0,
    oy = 0,
    symbolBank = {}
  }, manifest), Enemy)

  -- Set idle sprite
  if entity.assets.images.sprite then
    entity.currentSprite = entity.assets.images.sprite

    assert(entity.assets.images.sprite.animations, 'Enemy must have a default sprite with a base idle animaton.')
    entity.currentAnimation = entity.assets.images.sprite.animations.factory('idle')
  end

  return entity
end

function Enemy:update(dt)
  self.currentAnimation:update(dt)
  --self.updateIntent()
  -- self.performAction(GameState)
end

function Enemy:draw()
  self.currentAnimation:draw(self.x, self.y, 0, 1, 1, self.ox or 0, self.oy or 0)
end

-----------------------------
---       UTILITIES       ---
-----------------------------

function Enemy:modify(flags)
  if flags then
    for key, value in pairs(flags) do
      self[key] = value
    end
  end
end

function Enemy:getBaseSymbols()
  return self.symbols
end

function Enemy:getSymbolById(id)
  local result = {}
  for _, v in pairs(self.symbols) do
    if v.id == id then
      result = v
    end
  end
  return result
end

function Enemy:setSprite(sprite)
  self.currentSprite = self.assets.images[sprite]
end

function Enemy:setAnimation(tag)
  self.currentAnimation:setTag(tag)
end

function Enemy:attack()
  self:setAnimation('attack')
  local playedOnce = false

  self.currentAnimation:onLoop(function()
    if not playedOnce then
      playedOnce = true
      self:setAnimation('idle')
    end
  end)
end

-- function Enemy:updateIntent()
--   if #self.attackPattern > 0 then
--     self.intent = self.attackPattern[self.patternIndex]
--     self.patternIndex = (self.patternIndex % #self.attackPattern) + 1
--   end
-- end

-- function Enemy:performAction(gameState)
--   if not self.intent then return end

--   if self.intent.type == self.baseintents.attack.type then
--     GameState.player:applyDamage(self.intent.amount)
--   elseif self.intent.type == self.baseintents.buff.type then
--     -- Apply buff to self (e.g., increase attack)
--   elseif self.intent.type == self.baseintents.debuff.type then
--     -- Apply debuff to player
--   end
-- end

-- function Enemy:takeDamage(amount)
--   self.hp = math.max(0, self.hp - amount)
-- end

-- function Enemy:isDead()
--   return self.hp <= 0
-- end

return Enemy
