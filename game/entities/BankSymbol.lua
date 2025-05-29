local deepcopy = require "utils.deepcopy"

local BankSymbol = {}
BankSymbol.__index = BankSymbol

BankSymbol.debug = Debug
BankSymbol.debugLabel = LogManagerColor.colorf("{green}[BankSymbol]{reset}")


-- TODO: based on player level.
BankSymbol.baseCapByLevel = {
    level_1 = 10,
    level_10 = 15,
    level_20 = 20,
}

function BankSymbol:new(symbol)
    local instance = {
        id = symbol.id,
        qty = symbol.bank_qty or 0,
        cap = Bank.baseCapByLevel.level_1, -- TODO: figure this part out.
    }

    if symbol.increase_cap then
        instance.cap = instance.cap + symbol.increase_cap
    end
    setmetatable(instance, self)

    return instance
end

function BankSymbol:increaseQuantity(value)
    if self.qty < self.cap then
        local distance_to_cap = self.cap - self.qty
        local increase = love.math.min(distance_to_cap, value)
        self.qty = self.qty + increase
    end

    LogManager.info(self.qty)
end

function BankSymbol:decreaseQuantity(value)
    if self.qty > 0 then
        local decrease = love.math.min(self.qty, value)
        self.qty = self.qty - decrease
    end
end

return BankSymbol
