-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end

-- Debug
Debug = true
LogManagerColor = require "lib.LogManagerColor"
LogManager = require "lib.LogManager"

-- Utils
Tween = require "utils.tween"

-- Config
Colors = require "config.Colors"
Fonts = require "config.Fonts"

-- Library
InputManager = require "lib.InputManager"
SceneManager = require "lib.SceneManager".newManager()
EventBusManager = require "lib.EventBusManager"
ManifestManager = require "lib.ManifestManager"

-- Components
Button = require "src.components.Button"

-- Entities
Reel = require "src.entities.Reel"
Hero = require "src.entities.Hero"
Enemy = require "src.entities.Enemy"
GameState = require "src.entities.GameState"

local sceneLabel = LogManagerColor.colorf('{green}[GameLoop]{reset}')

function love.load()
  LogManager.startSession()
  LogManager.info("%s ⌛ Game loading...", sceneLabel)
  GameState:load()
  LogManager.info("%s ✅ Game loaded!", sceneLabel)
end

function love.update(dt)
  Tween.update(dt)
  GameState:update(dt)
  SceneManager.update(dt)

  love.keyboard.resetInputStates()
end

function love.draw()
  love.graphics.clear(0, 0, 0, 0)
  SceneManager.draw()
  GameState:draw()
end

function love.quit()
  LogManager.shutdown()
end
