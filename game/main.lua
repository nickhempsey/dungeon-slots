-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end
Debug           = true
LogManagerColor = require "lib.LogManagerColor"
LogManager      = require "lib.LogManager"

-- Utils
Tween           = require "utils.tween"

-- Components
Button          = require "src.components.Button"

-- Libraries
ColorsManager   = require "lib.ColorsManager"
EntityManager   = require "lib.EntityManager"
EventBusManager = require "lib.EventBusManager"
FontsManager    = require "lib.FontsManager"
InputManager    = require "lib.InputManager"
ManifestManager = require "lib.ManifestManager"
SceneManager    = require "lib.SceneManager".newManager()
ViewportManager = require "lib.ViewportManager"

-- GameState and Entities are always loaded
Actor           = require "src.entities.Actor"
Bank            = require "src.entities.Bank"
Enemy           = require "src.entities.Enemy"
GameState       = require "src.entities.GameState"
Hero            = require "src.entities.Hero"
Lair            = require "src.entities.Lair"
LootTable       = require "src.entities.LootTable"
PhaseState      = require "src.entities.PhaseState"
Reel            = require "src.entities.Reel"
InitiativeState = require "src.entities.InitiativeState"
StatusEffect    = require "src.entities.StatusEffect"
Symbol          = require "src.entities.Symbol"


local sceneLabel = LogManagerColor.colorf('{green}[GameLoop]{reset}')

-------------------------------------
---              LOAD             ---
-------------------------------------
function love.load()
  LogManager.startSession()
  LogManager.info("%s ⌛ Game loading...", sceneLabel)
  local cursorImageData = love.image.newImageData("assets/images/cursor.png")
  local customCursor = love.mouse.newCursor(cursorImageData, 0, 0)
  love.mouse.setCursor(customCursor)


  ViewportManager:load()
  ViewportManager:update()

  FontsManager:load()
  FontsManager:loadBMP()

  GameState:load()
  GameState.resetRNG()
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
