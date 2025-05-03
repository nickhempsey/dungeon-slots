local pathDefined = require "utils.pathDefined"
local deepcopy = require "utils.deepcopy"
local json = require "utils.json"

ManifestManager = {}
ManifestManager.__index = ManifestManager
ManifestManager.debug = false -- Debug
ManifestManager.debugLabel = LogManagerColor.colorf('{green}[ManifestManager]{reset}')


--[[
    TODO: Pull in default dataset then pull in the users save data and merge them together.
    The default will handle scooping up all of the required assets and what not.
    The player save file will handle setting the stats and any other effectable property.
    TBD on what those actually are.
--]]


-- This is used for auto refreshing data when files are updated.
local lfs = love.filesystem

local fileWatchList = {}  -- [modulePath] = file path
local fileModtimes = {}   -- [modulePath] = last mod time
local watchInterval = 1.0 -- seconds
local timeSinceCheck = 0


---@param configPath string
---@param manifestId string
function ManifestManager.get(configPath, manifestId)
  assert(type(configPath) == "string", "Function 'getManifest': parameter 'configType' must be a string.")
  assert(type(manifestId) == "string", "Function 'getManifest': parameter 'manifestId' must be a string.")

  local modulePath = string.format("config.%s.%s.manifest", configPath, manifestId)
  local filePath = string.format("config/%s/%s/manifest.lua", configPath, manifestId)

  if not pathDefined(filePath) then
    LogManager.error(string.format("%s No manifest found for '%s/%s'", ManifestManager.debugLabel, configPath, manifestId))
    return nil
  end

  -- Add to watch list if not already tracked
  if not fileWatchList[modulePath] then
    fileWatchList[modulePath] = filePath
    local info = lfs.getInfo(filePath)
    fileModtimes[modulePath] = info and info.modtime or 0
  end

  local manifest = require(modulePath)
  return manifest, "config/" .. configPath .. "/" .. manifestId .. "/"
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
      output[k] = deepcopy(v)
    end
  end

  if ManifestManager.debug then
    LogManager.info(string.format("%s Loaded manifest", ManifestManager.debugLabel))
    LogManager.info(output)
  end
  return output
end

-- Grabs the related symbols, effects, abilities, etc and returns them to the parent object.
-- Has a cache object to reduce load times when items would be reused across characters/enemies/lair.
--
local relationalCache = {}
---@param configPath string
---@param manifestIds string[]
---@return table
function ManifestManager.insertRelationalTables(configPath, manifestIds)
  assert(type(configPath) == "string", "Function 'insertTables': parameter 'system' must be a string.")
  assert(type(manifestIds) == "table", "Function 'insertTables': parameter 'manifestIds' must be a table.")

  local output = {}
  for _, manifestId in ipairs(manifestIds) do
    local cacheKey = string.format("config.%s.%s.manifest", configPath, manifestId)
    if relationalCache[cacheKey] then
      table.insert(output, deepcopy(relationalCache[cacheKey]))
      if ManifestManager.debug then
        LogManager.info(string.format("%s Cache Hit: %s", ManifestManager.debugLabel, cacheKey))
      end
    else
      local manifest, directory = ManifestManager.get(configPath, manifestId)
      if manifest then
        local loadedValues = ManifestManager.loadValues(manifest, directory)
        table.insert(output, deepcopy(loadedValues))
        relationalCache[cacheKey] = loadedValues
        if ManifestManager.debug then
          LogManager.info(string.format("%s Cache Miss: '%s'", ManifestManager.debugLabel, cacheKey))
        end
      end
    end
  end

  return output
end

-- Handle the assets of a given manifest
--
---@param configPath string
---@param manifest table
---@return table
function ManifestManager.handleAssets(configPath, manifest)
  assert(type(configPath) == "string", "Function 'handleAssets': parameter 'configPath'")
  assert(type(manifest) == "table", "Function 'handleAssets': parameter 'manifest' must be a table.")

  -- LogManager.info(string.format("%s Loading assets", ManifestManager.debugLabel))

  local output = {}
  if type(manifest) ~= "table" then
    return output
  end

  for k, v in pairs(manifest) do
    output[k] = {}
    if k == 'images' then
      output[k] = ManifestManager.handleImages(configPath, v)
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


  return output
end

function ManifestManager.handleImages(configPath, images)
  local output = {}
  if type(images) ~= 'table' then
    return output
  end
  for key, data in pairs(images) do
    assert(data.src, string.format("%s Missing 'src' for image: %s %s", ManifestManager.debugLabel, configPath, key))
    local imagePath = configPath .. data.src
    local image = love.graphics.newImage(imagePath)

    local animations = nil
    if data.animation then
      local animationPath = configPath .. data.animation
      if pathDefined(animationPath) then
        local animationJson = love.filesystem.read(animationPath)
        local decodedJson = json.decode(animationJson)
        animations = AnimationManager.buildFromAseprite(decodedJson)
      end
    end

    output[key] = {
      image = image,
      animations = animations
    }
  end

  return output;
end

function ManifestManager.handleFonts(configPath, fonts)
end

function ManifestManager.handleSounds(configPath, sounds)
end

-- Povides updates to the manifests in realtime so that the game doesn't need to be relaunched.
---
---@param dt number
---@return any
function ManifestManager.update(dt)
  timeSinceCheck = timeSinceCheck + dt
  if timeSinceCheck < watchInterval then return end
  timeSinceCheck = 0

  for modulePath, filePath in pairs(fileWatchList) do
    local info = lfs.getInfo(filePath)
    if info and info.modtime > fileModtimes[modulePath] then
      fileModtimes[modulePath] = info.modtime
      package.loaded[modulePath] = nil
      relationalCache[modulePath] = nil

      LogManager.info(string.format("%s Reloaded '%s'", ManifestManager.debugLabel, modulePath))
    end
  end
end

return ManifestManager
