local deepcopy = require "utils.deepcopy"

--[[
  Reel

  Allows you to define a “reel” of symbols, each with a `qty` weight,
  and efficiently spin for a random symbol in proportion to its weight.

  Example:
    local Reel = require "Reel"

    local reel = Reel.new({
      { id = "defense",  qty = 5  },  -- ~16.7% chance
      { id = "heal",     qty = 10 },  -- ~33.3% chance
      { id = "mobility", qty = 15 },  -- ~50.0% chance
    })

    local pick = reel:spin()  -- returns "defense" or "heal" or "mobility"
--]]

local Reel = {}
Reel.__index = Reel

Reel.debug = Debug
Reel.debugLabel = LogManagerColor.colorf('{green}[Reel]{reset}')

--[[
  Constructor

  symbols : array of tables { id = <any>, qty = <positive number> }
  Returns a new Reel instance.
--]]
function Reel:new(symbols)
  assert(type(symbols) == "table", "symbols must be a table")
  local instance = setmetatable({
    symbols          = symbols,
    current          = {},
    previous         = {},
    before           = {},
    after            = {},
    slots            = 3,
    decrementingOdds = false,
    tempReel         = {} -- Used during roll to make a copy of the reel and decrement symbol values to adjust odds.
  }, self)
  instance:buildCumulative()

  -- This is to build up a bit of history so we can use them
  -- in our before and after position on the reel.
  instance:spinReel()
  instance:spinReel()
  instance:spinReel()
  instance:spinReel()
  instance:spinReel()

  LogManager.info(instance.previous)

  return instance
end

--[[
  buildCumulative()

  Builds two things:
    1. self.cumulative : array of { id = <symbol id>, cumWeight = <number> }
       where cumWeight is the running total up to and including that symbol.
    2. self.totalWeight : the sum of all qtys.

  This lets us do a binary‐search spin in O(log N).
--]]
function Reel:buildCumulative()
  self.tempReel = {
    symbols = deepcopy(self.symbols),
    cumulative = {},
    totalWeight = 0
  }

  self:updateCumulative(0, 'initial load')
end

--- Updates the tempReel
---@param iterator number|nil
function Reel:updateCumulative(iterator, reason)
  LogManager.info(string.format("-------- START UPDATE: %s %s--------", reason, iterator))
  local total = 0

  self.tempReel.cumulative = {}
  self.tempReel.totalWeight = 0

  for i, symbol in ipairs(self.tempReel.symbols) do
    assert(type(symbol.qty) == "number" and symbol.qty > 0, string.format("symbol[%d].qty must be a positive number", i))

    total = total + symbol.qty
    self.tempReel.cumulative[i] = {
      id     = symbol.id,
      weight = total,
    }
  end

  assert(total > 0, "Total weight must be > 0")
  self.tempReel.totalWeight = total


  for _, symbol in pairs(self.tempReel.symbols) do
    LogManager.info(string.format("%s: %d in %d or %d%%", symbol.id, symbol.qty, self.tempReel.totalWeight,
      math.floor(symbol.qty / self.tempReel.totalWeight * 100)))
  end
  LogManager.info(" ")
  LogManager.info(string.format("-------- END UPDATE %s %s--------", reason, iterator))
end

--[[
  spin()

  Returns one symbol.id randomly, in proportion to its qty.
  Internally:
    1. Picks r ∈ [1, totalWeight]
    2. Binary‐searches cumulative[] for the first weight ≥ r
--]]
function Reel:spinSlot()
  local r = math.random(1, self.tempReel.totalWeight)
  local lo, hi = 1, #self.tempReel.cumulative

  while lo < hi do
    local mid = math.floor((lo + hi) * 0.5)
    if self.tempReel.cumulative[mid].weight < r then
      lo = mid + 1
    else
      hi = mid
    end
  end

  -- lo will be the index of the cumulative array.
  return self.tempReel.cumulative[lo].id
end

function Reel:spinReel()
  LogManager.info("-------- START REEL--------")
  if self.current then
    table.insert(self.previous, self.current)
  end

  self.current = {}
  for i = 1, self.slots do
    local symbolId = self:spinSlot()
    local symbol = self:getSymbolById(symbolId)
    table.insert(self.current, symbol)

    if not symbol then
      LogManager.info(string.format("%s not found", symbolId))
    end

    if self.decrementingOdds then
      local didUpdate = self:updateTempReelSymbolQty(symbolId, 1)
      if not didUpdate then
        LogManager.info(string.format("%s did not update", symbolId))
      end

      self:updateCumulative(i, 'Reel')
    end
  end

  self:setBeforeAndAfter()


  LogManager.info("")
  LogManager.info("")
  LogManager.info("-------- START RESULTS--------")
  for _, slot in pairs(self.current) do
    LogManager.info(string.format("%s", slot.id))
  end
  LogManager.info("-------- END RESULTS--------")
  LogManager.info("")
  LogManager.info("")
  LogManager.info("")
  LogManager.info("")
end

--- Updates the value of a tempReel symbol that has been selected.
---@param id string
---@param value number
---@return boolean confirmation
function Reel:updateTempReelSymbolQty(id, value)
  LogManager.info(string.format("---- Start Temp update %s ----", id))
  local updated = false
  for i, symbol in ipairs(self.tempReel.symbols) do
    if symbol.id == id then
      local qty = self.tempReel.symbols[i].qty
      LogManager.info(string.format("FOUND %s %d", symbol.id, qty))
      if qty > 1 then
        self.tempReel.symbols[i].qty = self.tempReel.symbols[i].qty - value
      else
        self.tempReel.symbols[i].qty = 1
      end
      updated = true
    end
  end
  LogManager.info(string.format("---- End Temp update %s ----", id))

  return updated
end

function Reel:getSymbolById(id)
  for _, symbol in pairs(self.symbols) do
    if symbol.id == id then
      return symbol
    end
  end

  return nil
end

function Reel:getCurrent()
  return self.current
end

function Reel:getPrevious()
  return self.previous
end

function Reel:setBeforeAndAfter()
  if #self.previous > 2 then
    local beforeIdx = love.math.random(1, #self.previous)
    local before = self.previous[beforeIdx]
    self.before = before

    local afterIdx = love.math.random(1, #self.previous)
    local after = self.previous[afterIdx]
    self.after = after
  end
end

function Reel:draw()
end

return Reel
