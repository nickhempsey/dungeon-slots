local Actor = require "src.entities.Actor"
local Bank = require "src.entities.Bank"

local Hero = setmetatable({}, { __index = Actor })
Hero.__index = Hero

Hero.debug = Debug
Hero.debugLabel = LogManagerColor.colorf('{green}[Hero]{reset}')

-- Instantiate a new hero by their id.
--
---@param id string
---@diagnostic disable-next-line: duplicate-set-field
function Hero:new(id)
  local hero = Actor:new('Hero', id)

  assert(hero, 'Hero failed to load')

  setmetatable(hero, Hero)

  hero.bank     = Bank:new()
  hero.currency = {} -- map e.g. { gold=0, gems=0 }
  hero.reels    = {} -- list of Reel
  hero.xpAmount = 0
  hero.xpRecord = { amount = 0 }

  LogManager.info(string.format("%s New Hero: %s", Hero.debugLabel, id))

  return hero
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
  self.currentAnimation:draw(self.x, self.y, 0, 1, 1, self.ox or 0, self.oy or 0)
end

-----------------------------
---       UTILITIES       ---
-----------------------------

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
