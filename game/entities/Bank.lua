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
    lastUpdated = nil,
    current = nil,
  }

  for _, symbol in pairs(symbols) do
    local data = {
      id = symbol.id,
      qty = symbol.bank_qty or 0,
      cap = Bank.baseCapByLevel.level_1, -- TODO: figure this part out.
      assets = deepcopy(symbol.assets)
    }

    if symbol.increase_cap then
      data.cap = data.cap + symbol.increase_cap
    end

    instance.symbols[symbol.id] = data
  end

  setmetatable(instance, self)

  if Bank.debug then
    LogManager.info("%s Added symbols", Bank.debugLabel)
  end
  return instance
end

return Bank
