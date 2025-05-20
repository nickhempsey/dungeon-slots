-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end
Debug           = true

-- Utils
Tween           = require "utils.tween"

-- Engine
I18n            = require "engine.LocalizationManager"
LogManagerColor = require "engine.LogManagerColor"
LogManager      = require "engine.LogManager"
ColorsManager   = require "engine.ColorsManager"
CursorManager   = require "engine.CursorManager"
EntityManager   = require "engine.EntityManager"
EventBusManager = require "engine.EventBusManager"
FontsManager    = require "engine.FontsManager"
InputManager    = require "engine.InputManager"
ManifestManager = require "engine.ManifestManager"
SceneManager    = require "engine.SceneManager".newManager()
ViewportManager = require "engine.ViewportManager"
TooltipManager  = require "engine.TooltipManager"

-- Components
Button          = require "components.Button"
Tooltip         = require "components.Tooltip"

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

-------------------------------------
---              LOAD             ---
-------------------------------------
function love.load()
  I18n.load('en')

  LogManager.startSession()
  LogManager.info(I18n.t('ui.main.loading', sceneLabel))

  CursorManager.load()

  -- TooltipManager.debugPositions()

  ViewportManager:load()
  ViewportManager:update()

  FontsManager:load()
  FontsManager:loadBMP()

  GameState:load()
  GameState.resetRNG()

  LogManager.info(I18n.t('ui.main.loaded', sceneLabel))
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

  CursorManager.draw()
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
