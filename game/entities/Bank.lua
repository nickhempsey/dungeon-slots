local deepcopy = require "utils.deepcopy"

local Bank = {}
Bank.__index = Bank

Bank.debug = Debug
Bank.debugLabel = LogManagerColor.colorf('{green}[Bank]{reset}')

-- TODO: based on player level.
Bank.baseCapByLevel = {
  level_1 = 10,
  level_10 = 15,
  level_20 = 20,
}

function Bank:new(symbols)
  if not symbols then return end

  local instance = {
    symbols = {},
    lastUpdated = os.time(),
    current = nil,
  }

  for _, symbol in pairs(symbols) do
    instance.symbols[symbol.id] = BankSymbol:new(symbol)
  end

  setmetatable(instance, self)

  if Bank.debug then
    LogManager.info("%s Added symbols", Bank.debugLabel)
    LogManager.info(instance)
  end

  self:subscribeToReel()

  return instance
end

function Bank:load()

end

--- Get a symbol in the this bank by the id.
---@param id string
---@return table|nil
function Bank:getSymbolById(id)
  LogManager.info('has symbol?')
  LogManager.info(id)
  LogManager.info(self.symbols)
  -- if self.symbols then
  --   LogManager.info(self.symbols)
  --   if self.symbols[id] then
  --     return self.symbols[id]
  --   end
  -- end

  return nil
end

--- Get the quantity of the symbol by it's id
---
---@param symbolId string
---@return integer
function Bank:getSymbolQuantity(symbolId)
  local symbol = self:getSymbolById(symbolId)

  if symbol then
    return symbol.qty
  end

  return 0
end

--- Increase the quantity of the selected symbols
---@param symbolId string
---@param quantity integer
function Bank:increaseSymbolQuantity(symbolId, quantity)

end

function Bank:onReelSpun(reel)
  if self.symbols then
    LogManager.info('Bank:onReelSpun')
    LogManager.info(self.symbols)
  end
  local counts = {}
  for _, symbol in pairs(reel.selected) do
    local id = symbol.id
    if counts[id] then
      counts[id] = counts[id] + 1
    else
      counts[id] = 1
    end
  end

  LogManager.info("%s reel has been spun", self.debugLabel)
  LogManager.info(counts)

  for key, value in pairs(counts) do
    local Symbol = self:getSymbolById(key)

    if Symbol then
      Symbol:increaseQuantity(value)
    end
  end
end

function Bank:subscribeToReel()
  EventBusManager:subscribe('reel_spun_end', Bank.onReelSpun, self, 10, self)
end

return Bank
