local Hero = {}
Hero.__index = Hero

Hero.debug = Debug
Hero.debugLabel = LogManagerColor.colorf('{green}[Hero]{reset}')

-- Instantiate a new hero by their id.
--
---@param heroId string
function Hero:new(heroId)
  assert(type(heroId) == "string", "Function 'new': parameter 'heroId' must be a string.")
  local hero = setmetatable({
    currentSprite = nil,
    currentAnimation = nil,
    x = 100,
    y = 100,
  }, Hero)

  LogManager.info(string.format("%s New hero: %s", Hero.debugLabel, heroId))
  local manifest = hero.loadManifest(heroId)
  if manifest then
    for k, v in pairs(manifest) do
      hero[k] = v
    end
  end

  hero.currentSprite = hero.assets.images.sprite
  LogManager.info(hero.assets.images)
  hero.currentAnimation = hero.currentSprite.animations.factory('idle')

  -- hero.currentAnimation.setTag('idle')

  return hero
end

-- Gather all of the required resources from the manifest.
--
---@param heroId string
function Hero.loadManifest(heroId)
  assert(type(heroId) == "string", "Function 'loadManifest': parameter 'heroId' must be a string.")
  LogManager.info(string.format("%s Loading", Hero.debugLabel))

  local manifest, directory = ManifestManager.get('heroes', heroId)
  local output = {}
  if manifest then
    output = ManifestManager.loadValues(manifest, directory)
    LogManager.info(string.format(" %s loaded", Hero.debugLabel))
    -- LogManager.info(output)
  else
    LogManager.error("%s No manifest found for '%s'", Hero.debugLabel, heroId)
  end
  return output
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
