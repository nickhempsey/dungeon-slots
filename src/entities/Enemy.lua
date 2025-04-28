Enemy = {}
Enemy.__index = Enemy

Enemy.debug = Debug

Enemy.baseintents = {
  attack = { type = "attack", amount = 10 },
  buff = { type = "buff", amount = 10 },
  debuff = { type = "debuff", amount = 10 },
  block = { type = "block", amount = 10 },
  run = { type = "run", amount = 10 },
}

function Enemy:new(name, maxHp, baseSymbols)
  local enemy = setmetatable({}, Enemy)
  enemy.name = name
  enemy.hp = maxHp
  enemy.maxHp = maxHp

  enemy.baseSymbols = {} -- your default reel pool
  enemy.abilities = {}

  enemy.statusEffects = {}

  -- What it plans to do next turn
  -- attack | buff | debuff | block | run ... etc
  enemy.intent = nil

  -- Array of actions it cycles through
  -- enemy.attackPattern = attackPattern or {}
  enemy.patternIndex = 1
  return enemy
end

function Enemy:updateIntent()
  if #self.attackPattern > 0 then
    self.intent = self.attackPattern[self.patternIndex]
    self.patternIndex = (self.patternIndex % #self.attackPattern) + 1
  end
end

function Enemy:performAction(gameState)
  if not self.intent then return end

  if self.intent.type == self.baseintents.attack.type then
    GameState.player:applyDamage(self.intent.amount)
  elseif self.intent.type == self.baseintents.buff.type then
    -- Apply buff to self (e.g., increase attack)
  elseif self.intent.type == self.baseintents.debuff.type then
    -- Apply debuff to player
  end
end

function Enemy:takeDamage(amount)
  self.hp = math.max(0, self.hp - amount)
end

function Enemy:isDead()
  return self.hp <= 0
end

return Enemy
