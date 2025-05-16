local Enemy = setmetatable({}, { __index = Actor })
Enemy.__index = Enemy

Enemy.debug = Debug
Enemy.debugLabel = LogManagerColor.colorf("{red}[Enemy]{reset}")

-- Instantiate a new hero by their id.
--
---@param id string
---@diagnostic disable-next-line: duplicate-set-field
function Enemy:new(id)
  assert(type(id) == "string", "Enemy:new 'new': parameter 'id' must be a string.")

  local enemy = Actor:new('Enemy', id)
  assert(enemy, 'Enemy failed to load')

  setmetatable(enemy, Enemy)
  LogManager.info(string.format("%s New enemy: %s", Enemy.debugLabel, id))

  EntityManager.register(enemy)

  return enemy
end

function Enemy:update(dt)
  self.currentAnimation:update(dt)
end

function Enemy:draw()
  self.currentAnimation:draw(self.x, self.y, 0, 1, 1, self.ox or 0, self.oy or 0)
end

-----------------------------
---       UTILITIES       ---
-----------------------------

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
