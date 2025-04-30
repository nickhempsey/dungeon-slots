local pathDefined = require "utils.pathDefined"

ManifestManager = {}
ManifestManager.__index = ManifestManager
ManifestManager.debug = Debug
ManifestManager.debugLabel = LogManagerColor.colorf('{green}[ManifestManager]{reset}')

---@param system string
---@param manifestId string
function ManifestManager.getDefault(system, manifestId)
  assert(type(system) == "string", "Function 'getManifest': parameter 'system' must be a string.")
  assert(type(manifestId) == "string", "Function 'getManifest': parameter 'manifestId' must be a string.")

  local manifest = nil

  local path = "config/" .. system .. "/" .. manifestId .. "/manifest"
  if pathDefined(path .. ".lua") then
    manifest = require(path)
  else
    LogManager.error(string.format("%s No manifest found for '%s/%s'", ManifestManager.debugLabel, system, manifestId))
  end

  return manifest
end

---@param manifest table
---@return table
function ManifestManager.loadValues(manifest)
  assert(type(manifest) == "table", "Function 'loadValues': parameter 'manifest' must be a table.")

  local output = {}

  for k, v in pairs(manifest) do
    if k == 'symbols' then
      output[k] = ManifestManager.insertRelationalTables('symbols', v)
    elseif k == 'effects' then
      output[k] = ManifestManager.insertRelationalTables('effects', v)
    elseif k == 'abilities' then
      output[k] = ManifestManager.insertRelationalTables('abilities', v)
    else
      output[k] = v
    end
  end

  if ManifestManager.debug then
    LogManager.info(string.format("%s Loaded manifest", ManifestManager.debugLabel))
    LogManager.info(output)
  end
  return output
end

---@param system string
---@param manifestIds string[]
---@return table
function ManifestManager.insertRelationalTables(system, manifestIds)
  assert(type(system) == "string", "Function 'insertTables': parameter 'system' must be a string.")
  assert(type(manifestIds) == "table", "Function 'insertTables': parameter 'manifestIds' must be a table.")

  local output = {}

  for _, manifestId in ipairs(manifestIds) do
    local manifest = ManifestManager.getDefault(system, manifestId)
    table.insert(output, manifest)
  end

  return output
end

return ManifestManager
