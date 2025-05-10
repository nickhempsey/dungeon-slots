local tableMerge = {}

--- Shallow Table Merge
---
---@param t1 table
---@param t2 table
function tableMerge.shallow(t1, t2)
  local result = {}
  for k, v in pairs(t1) do result[k] = v end
  for k, v in pairs(t2) do result[k] = v end
  return result
end

--- Deep Table Merge
---
---@param t1 table
---@param t2 table
function tableMerge.deep(t1, t2)
  local result = {}

  for k, v in pairs(t1) do
    if type(v) == "table" then
      result[k] = tableMerge.deep(v, {})
    else
      result[k] = v
    end
  end

  for k, v in pairs(t2) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = tableMerge.deep(result[k], v)
    else
      result[k] = v
    end
  end

  return result
end

--- Is array check
---
---@param t table
function tableMerge.isArray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

--- Deep Table Merge with array support
---
---@param t1 table
---@param t2 table
function tableMerge.deepMergeWithArray(t1, t2)
  local result = {}

  for k, v in pairs(t1) do
    if type(v) == "table" then
      result[k] = tableMerge.isArray(v) and { table.unpack(v) } or tableMerge.deepMergeWithArray(v, {})
    else
      result[k] = v
    end
  end

  for k, v in pairs(t2) do
    if type(v) == "table" and type(result[k]) == "table" then
      if tableMerge.isArray(v) and tableMerge.isArray(result[k]) then
        for _, item in ipairs(v) do
          table.insert(result[k], item)
        end
      else
        result[k] = tableMerge.deepMergeWithArray(result[k], v)
      end
    else
      result[k] = v
    end
  end

  return result
end

--- Deep Table Merge with metatable support
---
---@param t1 table
---@param t2 table
function tableMerge.deepMergePreserveMeta(t1, t2)
  local result = tableMerge.deepMergeWithArray(t1, t2)
  setmetatable(result, getmetatable(t1))
  return result
end

return tableMerge
