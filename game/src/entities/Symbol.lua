Symbol = {}
Symbol.__index = Symbol


function Symbol:new()
  local symbol = setmetatable({}, Symbol)

  return symbol
end

function Symbol:load()

end

function Hero:getDefaultManifest(symbolId)

end

-- This can be aquired from a default mainfest or a save file.
function Hero:loadManifest(manifest)
  assert(type(manifest) == "table", "Function 'loadManifest': parameter must be a table.")
  if type(manifest) == 'table' then
    for k, v in pairs(manifest) do
      Hero[k] = v
    end
  end
end

return Symbol
