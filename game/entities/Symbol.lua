local tableMerge = require "utils.tableMerge"

local Symbol = {}
Symbol.__index = Symbol


function Symbol:new(initialValues)
  local instance = setmetatable(tableMerge({
    qty         = 0,
    cap         = 10,
    probability = 0,
  }, initialValues), self)

  return instance
end

function Symbol:load()

end

return Symbol
