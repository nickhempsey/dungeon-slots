-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end

-- Debug
Debug = true
LogManagerColor = require "lib.LogManagerColor"
LogManager = require "lib.LogManager"

-- Utils
Tween = require "utils.tween"

-- Libraries
FontsManager = require "lib.FontsManager"
ColorsManager = require "lib.ColorsManager"
InputManager = require "lib.InputManager"
SceneManager = require "lib.SceneManager".newManager()
EventBusManager = require "lib.EventBusManager"
ManifestManager = require "lib.ManifestManager"
ViewportManager = require "lib.ViewportManager"

-- Components
Button = require "src.components.Button"

-- Entities
Reel = require "src.entities.Reel"
Hero = require "src.entities.Hero"
Enemy = require "src.entities.Enemy"
GameState = require "src.entities.GameState"

local sceneLabel = LogManagerColor.colorf('{green}[GameLoop]{reset}')

-------------------------------------
---              LOAD             ---
-------------------------------------
function love.load()
  ViewportManager:load()
  ViewportManager:update()

  FontsManager:load()
  FontsManager:loadBMP()


  LogManager.startSession()
  LogManager.info("%s ⌛ Game loading...", sceneLabel)
  GameState:load()
  LogManager.info("%s ✅ Game loaded!", sceneLabel)
end

-------------------------------------
---            UPDATE             ---
-------------------------------------
function love.update(dt)
  Tween.update(dt)
  GameState:update(dt)
  SceneManager.update(dt)

  love.keyboard.resetInputStates()
end

-------------------------------------
---            RESIZE             ---
-------------------------------------
function love.resize()
  ViewportManager:update()
end

-------------------------------------
---              DRAW             ---
-------------------------------------
function love.draw()
  -- Resets the screen and canvas on every draw
  -- Prevents left over elements hanging around.
  ViewportManager:clearCanvas()

  -- ALL Scenes, states, etc get rendered here.
  SceneManager.draw()
  GameState:draw()

  -- Now draw the canvas to the real screen, scaled and centered
  ViewportManager:scaleCanvas()
end

-------------------------------------
---              QUIT             ---
-------------------------------------
function love.quit()
  LogManager.shutdown()
end
