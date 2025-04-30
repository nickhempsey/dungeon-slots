Hero = {}
Hero.__index = Hero

Hero.debug = Debug
Hero.debugLabel = LogManagerColor.colorf('{green}[Hero]{reset}')

---@param heroId string
function Hero:new(heroId)
  assert(type(heroId) == "string", "Function 'new': parameter 'heroId' must be a string.")
  local Hero = setmetatable({}, Hero)

  LogManager.info(string.format("%s New hero: %s", Hero.debugLabel, heroId))
  local manifest = Hero.loadManifest(heroId)
  if manifest then
    for k, v in pairs(manifest) do
      Hero[k] = v
    end
  end

  return Hero
end

---@param heroId string
function Hero.loadManifest(heroId)
  assert(type(heroId) == "string", "Function 'loadManifest': parameter 'heroId' must be a string.")
  LogManager.info(string.format("%s Loading", Hero.debugLabel))

  local manifest, directory = ManifestManager.get('heroes', heroId)
  local output = {}
  if manifest then
    output = ManifestManager.loadValues(manifest, directory)
    LogManager.info(string.format(" %s loaded", Hero.debugLabel))
  else
    LogManager.error("%s No manifest found for '%s'", Hero.debugLabel, heroId)
  end
  return output
end

function Hero:load()

end

function Hero:update(dt)

end

function Hero:getBaseSymbols()
  return self.symbols
end

function Hero:load()
  Hero:subscribeToEvents()
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
