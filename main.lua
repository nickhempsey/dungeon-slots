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
EventBusManager = require "lib.EventBusManager"
LogManager = require "lib.LogManager"
TweenManager = require "lib.TweenManager"

-- Components
Button = require "src.components.Button"

-- Entities
Reel = require "src.entities.Reel"
Player = require "src.entities.Player"
GameState = require "src.entities.GameState"


function love.load()
  LogManager.startSession()
  LogManager.info("Game booting...")
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
  LogManager.shutdown()
end
