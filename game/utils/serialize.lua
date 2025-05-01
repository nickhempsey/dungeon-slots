local function serialize(value, depth)
  depth = depth or 0
  local indent = string.rep("  ", depth)

  if type(value) == "table" then
    local parts = { "{" }
    for k, v in pairs(value) do
      local keyStr = tostring(k)
      local valStr = serialize(v, depth + 1)
      table.insert(parts, indent .. "  [" .. keyStr .. "] = " .. valStr .. ",")
    end
    table.insert(parts, indent .. "}")
    return table.concat(parts, "\n")
  elseif type(value) == "string" then
    return string.format("%q", value) -- wrap strings in quotes
  else
    return tostring(value)
  end
end

return serialize
