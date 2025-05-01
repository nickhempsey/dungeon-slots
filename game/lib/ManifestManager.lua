local pathDefined = require "utils.pathDefined"

ManifestManager = {}
ManifestManager.__index = ManifestManager
ManifestManager.debug = Debug
ManifestManager.debugLabel = LogManagerColor.colorf('{green}[ManifestManager]{reset}')


--[[
    TODO: Pull in default dataset then pull in the users save data and merge them together.
    The default will handle scooping up all of the required assets and what not.
    The player save file will handle setting the stats and any other effectable property.
    TBD on what those actually are.
--]]


---@param configPath string
---@param manifestId string
function ManifestManager.get(configPath, manifestId)
  assert(type(configPath) == "string", "Function 'getManifest': parameter 'configType' must be a string.")
  assert(type(manifestId) == "string", "Function 'getManifest': parameter 'manifestId' must be a string.")

  local manifest = nil

  local directory = "config/" .. configPath .. "/" .. manifestId .. "/"
  if pathDefined(directory .. "manifest.lua") then
    manifest = require(directory .. "manifest")
  else
    LogManager.error(string.format("%s No manifest found for '%s/%s'", ManifestManager.debugLabel, configPath, manifestId))
  end

  return manifest, directory
end

---@param manifest table
---@return table
function ManifestManager.loadValues(manifest, directory)
  assert(type(manifest) == "table", "Function 'loadValues': parameter 'manifest' must be a table.")
  assert(type(directory) == "string", "Function 'loadValues': parameter 'directory' must be a string.")

  local output = {}

  for k, v in pairs(manifest) do
    if k == 'symbols' then
      output[k] = ManifestManager.insertRelationalTables('symbols', v)
    elseif k == 'effects' then
      output[k] = ManifestManager.insertRelationalTables('effects', v)
    elseif k == 'abilities' then
      output[k] = ManifestManager.insertRelationalTables('abilities', v)
    elseif k == 'assets' then
      output[k] = ManifestManager.handleAssets(directory, v)
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

---@param configPath string
---@param manifestIds string[]
---@return table
function ManifestManager.insertRelationalTables(configPath, manifestIds)
  assert(type(configPath) == "string", "Function 'insertTables': parameter 'system' must be a string.")
  assert(type(manifestIds) == "table", "Function 'insertTables': parameter 'manifestIds' must be a table.")

  local output = {}

  for _, manifestId in ipairs(manifestIds) do
    local manifest, directory = ManifestManager.get(configPath, manifestId)
    if manifest then
      local loadedValues = ManifestManager.loadValues(manifest, directory)
      table.insert(output, loadedValues)
    end
  end

  return output
end

function ManifestManager.handleAssets(configPath, manifest)
  assert(type(configPath) == "string", "Function 'handleAssets': parameter 'configPath'")
  assert(type(manifest) == "table", "Function 'handleAssets': parameter 'manifest' must be a table.")

  -- LogManager.info(string.format("%s Loading assets", ManifestManager.debugLabel))

  -- LogManager.info(manifest)
  -- local directory = "config/" .. configPath .. "/" .. manifest.id .. "/"

  local output = {}
  if type(manifest) == "table" then
    for k, v in pairs(manifest) do
      output[k] = {}
      if k == 'images' then
        for k2, v2 in pairs(v) do
          if pathDefined(configPath .. v2) then
            LogManager.info(configPath .. v2)
            output[k][k2] = love.graphics.newImage(configPath .. v2)
          end
        end
      elseif k == 'fonts' then
        for k2, v2 in pairs(v) do
          if pathDefined(configPath .. v2) then
            output[k][k2] = love.graphics.newFont(configPath .. v2)
          end
        end
      elseif k == 'sounds' then
        for k2, v2 in pairs(v) do
          if pathDefined(configPath .. v2) then
            output[k][k2] = love.audio.newSound(configPath .. v2)
          end
        end
      end
    end
  end

  return output
end

return ManifestManager
