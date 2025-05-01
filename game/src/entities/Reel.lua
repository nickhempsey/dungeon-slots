Reel = {}
Reel.__index = Reel

Reel.debug = Debug

function Reel:new(symbols)
  local data = {
    symbols = symbols,
    currentSpin = {},
  }
  setmetatable(data, self)
  return data
end

function Reel:spin()
  self.currentSpin = {}
  for i = 1, 3 do
    local idx = love.math.random(1, #self.symbols)
    table.insert(self.currentSpin, self.symbols[idx])
  end
end

function Reel:getResults()
  return self.currentSpin
end

return Reel
