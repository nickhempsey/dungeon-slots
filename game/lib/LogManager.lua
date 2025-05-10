-- LogManager.lua
local LogManagerColor = require "lib.LogManagerColor"
local getTimestamp = require "utils.getTimestamp"
local serialize = require "utils.serialize"
local unpack = require "utils.unpack"

local LogManager = {}

LogManager.levels = {
  debug = { label = "DEBUG", color = "bright_black" },
  info  = { label = "INFO ", color = "cyan" },
  warn  = { label = "WARN ", color = "yellow" },
  error = { label = "ERROR", color = "bright_red" }
}

LogManager.enabledLevels = {
  debug = true,
  info = true,
  warn = true,
  error = true
}

LogManager.fileLoggingEnabled = true
LogManager.logFilePath = nil
local handleLogFile = nil


-- Start log session
function LogManager.startSession()
  if not love then
    LogManager.error("Love not found!", LogManager.logFilePath)
    return
  end
  if love.filesystem and LogManager.fileLoggingEnabled then
    if not love.filesystem.getInfo("logs") then
      love.filesystem.createDirectory("logs")
    end
    LogManager.logFilePath = "logs/session_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    handleLogFile = love.filesystem.newFile(LogManager.logFilePath, "w")
    handleLogFile:open("w")
  else
    print("LogManager: love.filesystem not available or file logging disabled.")
    LogManager.fileLoggingEnabled = false
  end

  LogManager.info("Log session started: %s", LogManager.logFilePath)
end

---@param text string
local function writeToFile(text)
  assert(type(text) == "string", "Function 'writeToFile': parameter must be a string.")

  if LogManager.fileLoggingEnabled and handleLogFile then
    handleLogFile:write(text .. "\n")
    handleLogFile:flush()
  end
end

-- Log a message
---@param level string
---@param message string|table
---@param ... any
function LogManager.log(level, message, ...)
  assert(type(level) == "string", "Function 'log': first parameter must be a string.")

  if not LogManager.enabledLevels[level] then return end

  local lvl = LogManager.levels[level]
  if not lvl then
    error("LogManager: unknown level '" .. tostring(level) .. "'")
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
    LogManagerColor.colorf(string.format("{%s}[%s]{reset}", lvl.color, lvl.label)),
    LogManagerColor.colorf("{bright_black}" .. timestamp .. "{reset}"),
    message
  )
  print(output)

  -- File output (plain, no colors)
  local plainOutput = string.format("[%s] %s %s", lvl.label, timestamp, message)
  writeToFile(plainOutput)
end

function LogManager.debug(msg, ...)
  LogManager.log("debug", msg, ...)
end

function LogManager.info(msg, ...)
  LogManager.log("info", msg, ...)
end

function LogManager.warn(msg, ...)
  LogManager.log("warn", msg, ...)
end

function LogManager.error(msg, ...)
  LogManager.log("error", msg, ...)
end

function LogManager.setLevelEnabled(level, enabled)
  LogManager.enabledLevels[level] = enabled
end

function LogManager.shutdown()
  if handleLogFile then
    LogManager.info("Log session closed.")
    handleLogFile:close()
  end
end

return LogManager
