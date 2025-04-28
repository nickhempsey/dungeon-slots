-- logger.lua
local LoggerColor = require "utils.LoggerColor"
local serialize = require "utils.serialize"
local getTimestamp = require "utils.getTimestamp"
local unpack = require "utils.unpack"

local Logger = {}

Logger.levels = {
  debug = { label = "DEBUG", color = "bright_cyan" },
  info  = { label = "INFO ", color = "cyan" },
  warn  = { label = "WARN ", color = "yellow" },
  error = { label = "ERROR", color = "bright_red" }
}

Logger.enabledLevels = {
  debug = true,
  info = true,
  warn = true,
  error = true
}

Logger.fileLoggingEnabled = true
Logger.logFilePath = nil
local logFileHandle = nil


-- Start log session
function Logger.startSession()
  if love and love.filesystem then
    if not love.filesystem.getInfo("logs") then
      love.filesystem.createDirectory("logs")
    end
    Logger.logFilePath = "logs/session_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    logFileHandle = love.filesystem.newFile(Logger.logFilePath, "w")
    logFileHandle:open("w")
    Logger.info("Log session started: %s", Logger.logFilePath)
  else
    print("Logger: love.filesystem not available, file logging disabled.")
    Logger.fileLoggingEnabled = false
  end
end

local function writeToFile(text)
  if Logger.fileLoggingEnabled and logFileHandle then
    logFileHandle:write(text .. "\n")
    logFileHandle:flush()
  end
end

-- Log a message
function Logger.log(level, message, ...)
  if not Logger.enabledLevels[level] then return end

  local lvl = Logger.levels[level]
  if not lvl then
    error("Logger: unknown level '" .. tostring(level) .. "'")
  end

  local timestamp = getTimestamp()

  -- If message is a table, serialize it to a string
  if type(message) == "table" then
    message = serialize(message)
  end

  -- Process additional arguments
  local args = { ... }
  for i = 1, #args do
    if type(args[i]) == "table" then
      args[i] = serialize(args[i])
    else
      args[i] = tostring(args[i]) -- always ensure string/safe type
    end
  end

  -- Now safely format the message
  if #args > 0 then
    message = string.format(message, unpack(args))
  end

  -- Console output
  local output = string.format(
    "%s %s %s",
    LoggerColor.colorf(string.format("{%s}[%s]{reset}", lvl.color, lvl.label)),
    LoggerColor.colorf("{bright_black}" .. timestamp .. "{reset}"),
    message
  )
  print(output)

  -- File output (plain, no colors)
  local plainOutput = string.format("[%s] %s %s", lvl.label, timestamp, message)
  writeToFile(plainOutput)
end

function Logger.debug(msg, ...)
  Logger.log("debug", msg, ...)
end

function Logger.info(msg, ...)
  Logger.log("info", msg, ...)
end

function Logger.warn(msg, ...)
  Logger.log("warn", msg, ...)
end

function Logger.error(msg, ...)
  Logger.log("error", msg, ...)
end

function Logger.setLevelEnabled(level, enabled)
  Logger.enabledLevels[level] = enabled
end

function Logger.shutdown()
  if logFileHandle then
    Logger.info("Log session closed.")
    logFileHandle:close()
  end
end

return Logger
