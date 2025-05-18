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
Tooltip         = require "src.components.Tooltip"

-- Libraries
ColorsManager   = require "lib.ColorsManager"
EntityManager   = require "lib.EntityManager"
EventBusManager = require "lib.EventBusManager"
FontsManager    = require "lib.FontsManager"
InputManager    = require "lib.InputManager"
ManifestManager = require "lib.ManifestManager"
SceneManager    = require "lib.SceneManager".newManager()
ViewportManager = require "lib.ViewportManager"
TooltipManager  = require "lib.TooltipManager"

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


  -- Tooltip:new('Right Bottom', 'left', 100, 76, 'right', 'bottom', -4)
  -- Tooltip:new('Left Bottom', 'left', 100, 76, 'left', 'bottom', -4)
  -- Tooltip:new('Right Top', 'left', 100, 76, 'right', 'top', -4)
  -- Tooltip:new('Left Top', 'left', 100, 76, 'left', 'top', -4)
  -- Tooltip:new('Center Bottom', 'left', 100, 76, 'center', 'bottom')
  -- Tooltip:new('Center Top', 'left', 100, 76, 'center', 'top')
  -- Tooltip:new('Right Center', 'left', 100, 76, 'right', 'center')
  -- Tooltip:new('Left Center', 'left', 100, 76, 'left', 'center')

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
