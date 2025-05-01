-- SaveManager.lua
local json = require "utils.json"

local SaveManager = {}

local saveFolder = "saves/" -- All saves will go here
local debugLabel = LogManagerColor.colorf('{yellow}[SaveManager]{reset}')

-- Ensure the save folder exists
function SaveManager.ensureSaveFolder()
  if not love.filesystem.getInfo(saveFolder) then
    love.filesystem.createDirectory(saveFolder)
  end
end

-- Save game data to a slot (e.g., "slot1")
function SaveManager.save(slotName, data)
  SaveManager.ensureSaveFolder()

  local path = saveFolder .. slotName .. ".json"
  local encoded, err = json.encode(data)

  if not encoded then
    error("Failed to encode save data: " .. tostring(err))
  end

  love.filesystem.write(path, encoded)
  LogManager.info("%s Saved '%s' to '%s'", debugLabel, slotName, path)
end

-- Load game data from a slot
function SaveManager.load(slotName)
  SaveManager.ensureSaveFolder()

  local path = saveFolder .. slotName .. ".json"

  if love.filesystem.getInfo(path) then
    local contents = love.filesystem.read(path)
    local data, err = json.decode(contents)

    if not data then
      error("Failed to decode save data: " .. tostring(err))
    end

    LogManager.info("%s Loaded '%s' from '%s'", debugLabel, slotName, path)

    return data
  else
    LogManager.info("%s No save for '%s' found at '%s'", debugLabel, slotName, path)
    return nil
  end
end

-- Check if a save slot exists
function SaveManager.exists(slotName)
  local path = saveFolder .. slotName .. ".json"
  return love.filesystem.getInfo(path) ~= nil
end

return SaveManager
