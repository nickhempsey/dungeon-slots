-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end

-- Debug
Debug = require "config.Debug"

-- Config
Colors = require "config.Colors"
Fonts = require "config.Fonts"

-- Library
InputManager = require "lib.InputManager"
SceneManager = require "lib.SceneManager".newManager()
EventBus = require "lib.EventBus"
Logger = require "lib.Logger"

-- Components
Button = require "src.components.Button"

-- Entities
Reel = require "src.entities.Reel"
Player = require "src.entities.Player"
GameState = require "src.entities.GameState"


function love.load()
  Logger.startSession()
  Logger.info("Game booting...")
  GameState:load()
end

function love.update(dt)
  GameState:update(dt)
  SceneManager.update(dt)

  love.keyboard.resetInputStates()
end

function love.draw()
  GameState:draw()
  SceneManager.draw()
end

function love.quit()
  Logger.shutdown()
end
