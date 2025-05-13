Symbol = {}
Symbol.__index = Symbol


function Symbol:new()
  local symbol = setmetatable({}, Symbol)

  return symbol
end

function Symbol:load()

end

return Symbol
