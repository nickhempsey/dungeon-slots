local pathDefined = require "utils.pathDefined"
local deepcopy = require "utils.deepcopy"
local json = require "utils.json"
local peachy = require "utils.peachy"

local function stripPrefix(name, prefix)
  local rest = name:sub(#prefix + 1)
  return rest:sub(1, 1):lower() .. rest:sub(2)
end

ManifestManager = {}
ManifestManager.__index = ManifestManager
ManifestManager.debug = false -- Debug
ManifestManager.debugLabel = LogManagerColor.colorf('{green}[ManifestManager]{reset}')
ManifestManager.storeRawAnimationJSON = false

local basePath = 'data'

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

-----------------------------
---     GET MANIFEST      ---
-----------------------------
--- Get the request Manifest
---
---@param manifestPath string
---@param manifestId string
function ManifestManager.get(manifestPath, manifestId)
  assert(type(manifestPath) == "string", "Function 'getManifest': parameter 'configType' must be a string.")
  assert(type(manifestId) == "string", "Function 'getManifest': parameter 'manifestId' must be a string.")

  local modulePath = string.format("%s.%s.%s.manifest", basePath, manifestPath, manifestId)
  local filePath = string.format("%s/%s/%s/manifest.lua", basePath, manifestPath, manifestId)

  if not pathDefined(filePath) then
    LogManager.error(string.format("%s No manifest found for '%s/%s'", ManifestManager.debugLabel, manifestPath,
      manifestId))
    return nil
  end

  -- Add to watch list if not already tracked
  if not fileWatchList[modulePath] then
    fileWatchList[modulePath] = filePath
    local info = lfs.getInfo(filePath)
    fileModtimes[modulePath] = info and info.modtime or 0
  end

  local manifest = require(modulePath)
  return manifest, basePath .. "/" .. manifestPath .. "/" .. manifestId .. "/"
end

-----------------------------
---   COLLECTION METHODS  ---
-----------------------------

--- Scan manifest for keys matching "^base[A-Z]" and return
--- a map { fieldNameWithoutPrefix = function, … } and call it.
---
---@param manifest table
function ManifestManager.collectDynamicFields(manifest)
  local output = {}

  for k, v in pairs(manifest) do
    local isDynamic = type(k) == "string" and k:match("^base[A-Z]") and type(v) == "function"
    if isDynamic then
      local field = stripPrefix(k, 'base')
      output[field] = v() -- call the fn, don't store
    end
  end

  return output
end

--- Scan manifest for keys matching "^roll[A-Z]" and return
--- a map { fieldNameWithoutPrefix = function, … } WITHOUT calling it.
---
---@param manifest table
function ManifestManager.collectOnDemandFields(manifest)
  local out = {}
  for k, v in pairs(manifest) do
    local isAsync = type(k) == "string" and k:match("^roll[A-Z]") and type(v) == "function"
    if isAsync then
      -- strip "roll", lower first letter of remainder, keep rest
      local field = stripPrefix(k, 'roll')
      out[field] = v -- store fn, don't call
    end
  end
  return out
end

--- Collect all static and relational tables.
---
---@param manifest table
---@return table
function ManifestManager.collectStaticAndRelationalValues(manifest, directory)
  assert(type(manifest) == "table", "Function 'collectStaticAndRelationalValues': parameter 'manifest' must be a table.")
  assert(type(directory) == "string",
    "Function 'collectStaticAndRelationalValues': parameter 'directory' must be a string.")

  local output = {}

  for k, v in pairs(manifest) do
    local isStatic = type(k) == "string" and type(v) ~= "function"
    if isStatic then
      if k == 'symbols' then
        output[k] = ManifestManager.handleRelationalTables('symbols', v)
      elseif k == 'effects' then
        output[k] = ManifestManager.handleRelationalTables('effects', v)
      elseif k == 'abilities' then
        output[k] = ManifestManager.handleRelationalTables('abilities', v)
      elseif k == 'assets' then
        output[k] = ManifestManager.handleAssets(directory, v)
      else
        output[k] = deepcopy(v)
      end
    end
  end

  if ManifestManager.debug then
    LogManager.info(string.format("%s Loaded manifest", ManifestManager.debugLabel))
    LogManager.info(output)
  end
  return output
end

-----------------------------
---    UNIQUE HANDLERS    ---
-----------------------------

-- Grabs the related symbols, effects, abilities, etc and returns them to the parent object.
-- Has a cache object to reduce load times when items would be reused across characters/enemies/lair.
--
local relationalCache = {}
---@param manifestPath string
---@param manifestIds string[]
---@return table
function ManifestManager.handleRelationalTables(manifestPath, manifestIds)
  assert(type(manifestPath) == "string", "Function 'insertTables': parameter 'system' must be a string.")
  assert(type(manifestIds) == "table", "Function 'insertTables': parameter 'manifestIds' must be a table.")

  local output = {}
  for _, manifestId in ipairs(manifestIds) do
    local cacheKey = string.format("data.%s.%s.manifest", manifestPath, manifestId)
    if relationalCache[cacheKey] then
      table.insert(output, deepcopy(relationalCache[cacheKey]))
      if ManifestManager.debug then
        LogManager.info(string.format("%s Cache Hit: %s", ManifestManager.debugLabel, cacheKey))
      end
    else
      local manifest = ManifestManager.loadEntityManifest(manifestPath, manifestId)
      table.insert(output, deepcopy(manifest))
      relationalCache[cacheKey] = manifest
      if ManifestManager.debug then
        LogManager.info(string.format("%s Cache Miss: '%s'", ManifestManager.debugLabel, cacheKey))
      end
    end
  end

  return output
end

-- Handle the assets of a given manifest
--
---@param manifestPath string
---@param manifest table
---@return table
function ManifestManager.handleAssets(manifestPath, manifest)
  assert(type(manifestPath) == "string", "Function 'handleAssets': parameter 'manifestPath'")
  assert(type(manifest) == "table", "Function 'handleAssets': parameter 'manifest' must be a table.")

  -- LogManager.info(string.format("%s Loading assets", ManifestManager.debugLabel))

  local output = {}
  if type(manifest) ~= "table" then
    return output
  end

  for k, v in pairs(manifest) do
    output[k] = {}
    if k == 'images' then
      output[k] = ManifestManager.handleImages(manifestPath, v)
    elseif k == 'fonts' then
      for k2, v2 in pairs(v) do
        if pathDefined(manifestPath .. v2) then
          output[k][k2] = love.graphics.newFont(manifestPath .. v2)
        end
      end
    elseif k == 'sounds' then
      for k2, v2 in pairs(v) do
        if pathDefined(manifestPath .. v2) then
          output[k][k2] = love.audio.newSound(manifestPath .. v2)
        end
      end
    end
  end


  return output
end

--- Handles setting any images and sprite animations to the entity
---
---@param manifestPath string The name of the path to get the to manifest.
---@param images table The table of images that are in the manifest.
function ManifestManager.handleImages(manifestPath, images)
  local output = {}
  if type(images) ~= 'table' then
    return output
  end
  for key, data in pairs(images) do
    assert(data.src, string.format("%s Missing 'src' for image: %s %s", ManifestManager.debugLabel, manifestPath, key))
    local imagePath = manifestPath .. data.src
    local image = love.graphics.newImage(imagePath)

    local animations = nil
    if data.animation then
      local jsonPath = manifestPath .. data.animation
      if pathDefined(jsonPath) then
        animations = {}
        local peachyData = love.filesystem.read(jsonPath)
        -- Optional: You can cache this parsed JSON if used in multiple sprites
        if ManifestManager.storeRawAnimationJSON then
          animations.raw = json.decode(peachyData)
        end
        animations.factory = function(tag)
          return peachy.new(jsonPath, image, tag)
        end
      end
    end

    output[key] = {
      image = image,
      animations = animations
    }
  end

  return output;
end

function ManifestManager.handleFonts(manifestPath, fonts)
end

function ManifestManager.handleSounds(manifestPath, sounds)
end

-----------------------------
---   PUBLIC METHODS   ---
-----------------------------
---
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

--- Used by Entities to load their manifests.
---
--- @param manifestPath string
--- @param id string
--- @return table|nil
function ManifestManager.loadEntityManifest(manifestPath, id)
  assert(type(manifestPath) == "string", "loadEntityManifest: 'type' must be a string.")
  assert(type(id) == "string", "loadEntityManifest: 'id' must be a string.")

  local manifest, directory = ManifestManager.get(manifestPath, id)
  if not manifest then
    return nil
  end

  local staticData  = ManifestManager.collectStaticAndRelationalValues(manifest, directory)
  local dynamicData = ManifestManager.collectDynamicFields(manifest)
  local rollFns     = ManifestManager.collectOnDemandFields(manifest)

  LogManager.info(rollFns)
  local entity = {}

  for k, v in pairs(staticData) do
    entity[k] = v
  end

  for k, v in pairs(dynamicData) do
    entity[k] = v
  end

  -- stash the compute-on-demand fns
  entity._rolls = rollFns

  function entity:roll(name, ...)
    local fn = self._rolls[name]
    assert(fn, ("No roll-field '%s'"):format(name))
    return fn(...)
  end

  if manifest.postInit then
    manifest.postInit(entity)
  end

  return entity
end

return ManifestManager
