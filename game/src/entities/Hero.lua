local tableMerge = require "utils.tableMerge"

local Hero = {}
Hero.__index = Hero

Hero.debug = Debug
Hero.debugLabel = LogManagerColor.colorf('{green}[Hero]{reset}')

-- Instantiate a new hero by their id.
--
---@param id string
function Hero:new(id)
  assert(type(id) == "string", "Function 'new': parameter 'id' must be a string.")
  local manifest = ManifestManager.loadEntityManifest("heroes", id)
  if not manifest then
    return nil
  end

  local entity = setmetatable(tableMerge.deepMergeWithArray({
    currentSprite = nil,
    currentAnimation = nil,
    x = 500,
    y = 0,
  }, manifest), Hero)

  -- Set idle sprite
  if entity.assets.images.sprite then
    entity.currentSprite = entity.assets.images.sprite

    assert(entity.assets.images.sprite.animations, 'Hero must have a default sprite with a base idle animaton.')
    entity.currentAnimation = entity.assets.images.sprite.animations.factory('idle')
  end

  return entity
end

-- Runs in love.load
function Hero:load()
  Hero:subscribeToEvents()
end

-- Runs in love.update
function Hero:update(dt)
  self.currentAnimation:update(dt)
end

-- Runs in love.draw
function Hero:draw()
  self.currentAnimation:draw(self.x, self.y)
end

-----------------------------
---       UTILITIES       ---
-----------------------------
---
function Hero:getBaseSymbols()
  return self.symbols
end

function Hero:getSymbolById(id)
  local result = {}
  for _, v in pairs(self.symbols) do
    if v.id == id then
      result = v
    end
  end
  return result
end

function Hero:setSprite(sprite)
  self.currentSprite = self.assets.images[sprite]
end

function Hero:setAnimation(tag)
  self.currentAnimation = self.currentSprite.animations.factory(tag)
end

function Hero:applyDamage(amount)
  local dmg = math.max(0, amount - self.stats.defense)
  self.stats.health = self.stats.health - dmg
end

function Hero:subscribeToEvents()
  EventBusManager:subscribe('hero_take_damage',
    function(amount)
      Hero:applyDamage(amount)
    end,
    'Hero',
    10)
end

return Hero
