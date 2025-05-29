local tableMerge = require "utils.tableMerge"

local Symbol = {}
Symbol.__index = Symbol


function Symbol:new(initialValues)
  local instance = setmetatable(tableMerge({
    x = 0,
    y = 0,

  }, initialValues), self)

  return instance
end

function Symbol:load()

end

function Symbol:isHover()
end

return Symbol
