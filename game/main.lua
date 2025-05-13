-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end

-- Debug
Debug = true
LogManagerColor = require "lib.LogManagerColor"
LogManager = require "lib.LogManager"

-- Utils
Tween = require "utils.tween"

-- Entities
Reel = require "src.entities.Reel"
Hero = require "src.entities.Hero"
Enemy = require "src.entities.Enemy"
Lair = require "src.entities.Lair"
GameState = require "src.entities.GameState"

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



local sceneLabel = LogManagerColor.colorf('{green}[GameLoop]{reset}')

-------------------------------------
---              LOAD             ---
-------------------------------------
function love.load()
  LogManager.startSession()
  LogManager.info("%s ⌛ Game loading...", sceneLabel)

  -- Clear out the system cache.
  love.math.setRandomSeed(os.time())
  love.math.random()
  love.math.random()
  love.math.random()

  ViewportManager:load()
  ViewportManager:update()

  FontsManager:load()
  FontsManager:loadBMP()

  GameState:load()
  LogManager.info("%s ✅ Game loaded!", sceneLabel)
end

-------------------------------------
---            UPDATE             ---
-------------------------------------
function love.update(dt)
  Tween.update(dt)
  SceneManager.update(dt)
  GameState:update(dt)

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
