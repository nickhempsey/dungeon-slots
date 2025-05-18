-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end
Debug           = true
LogManagerColor = require "engine.LogManagerColor"
LogManager      = require "engine.LogManager"

-- Utils
Tween           = require "utils.tween"

-- Components
Button          = require "components.Button"
Tooltip         = require "components.Tooltip"

-- Engine
ColorsManager   = require "engine.ColorsManager"
EntityManager   = require "engine.EntityManager"
EventBusManager = require "engine.EventBusManager"
FontsManager    = require "engine.FontsManager"
InputManager    = require "engine.InputManager"
ManifestManager = require "engine.ManifestManager"
SceneManager    = require "engine.SceneManager".newManager()
ViewportManager = require "engine.ViewportManager"
TooltipManager  = require "engine.TooltipManager"

-- State
GameState       = require "state.GameState"
InitiativeState = require "state.InitiativeState"
PhaseState      = require "state.PhaseState"

-- Entities
Actor           = require "entities.Actor"
Bank            = require "entities.Bank"
Enemy           = require "entities.Enemy"
Hero            = require "entities.Hero"
Lair            = require "entities.Lair"
LootTable       = require "entities.LootTable"
Reel            = require "entities.Reel"
StatusEffect    = require "entities.StatusEffect"
Symbol          = require "entities.Symbol"


local sceneLabel = LogManagerColor.colorf('{green}[GameLoop]{reset}')
-- local cursorImageData = love.image.newImageData("assets/images/cursor.png")
-- local debugImageData = love.image.newImageData("assets/images/cursor_debug.png")
-- DefaultCursor = love.mouse.newCursor(debugImageData, CursorImage:getWidth() / 2, CursorImage:getWidth() / 2)

-------------------------------------
---              LOAD             ---
-------------------------------------
function love.load()
  LogManager.startSession()
  LogManager.info("%s ⌛ Game loading...", sceneLabel)
  -- Hide the system cursor
  love.mouse.setVisible(false)


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

  TooltipManager.update(dt)
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

  TooltipManager.draw()
  -- Now draw the canvas to the real screen, scaled and centered
  ViewportManager:scaleCanvas()
end

-------------------------------------
---              QUIT             ---
-------------------------------------
function love.quit()
  LogManager.shutdown()
end
