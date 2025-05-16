local hexToRGBA = require "utils.hexToRGBA"

-----------------------
--   COMBAT SCENE    --
-----------------------
local scene = {}
local cur = SceneManager.current

scene.lair = nil

-- Stacking Scene Manager can be used to call a scenes modify function.
-- The modify function is intended to be used for changing specific
-- parts of a scene defined in the flags table. Each scene can have a
-- unique modify function that handles received flags respectively.
--
-- The modify function is not intended to restart a scene, to do this
-- first purge then add the scene again.
function scene.modify(flags)
end

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  local lairId = "tutorial_lair"
  local lair = Lair:new(lairId)

  if lair then
    LogManager.info(lair)
    lair:setStage()

    assert(lair.stageSet, string.format('The stage %s failed to set properly.', lairId))
  end

  local initiative = InitiativeState:new()
  initiative:roll()
  -- temp tick forward to 0 eventually will check for loadmode first.
  initiative:advanceInitiative()

  -- Create References for easier system wide management
  GameState.lair       = lair
  GameState.initiative = initiative

  IncrementTurn        = Button:new("Increment Turn", 8, 48, function()
    initiative:advanceInitiative()
  end)
  DecrementTurn        = Button:new("Decrement Turn", 8, 68, function()
    initiative:reverseInitiative()
  end)
  IncrementPhase       = Button:new("Increment Phase", 8, 96, function()
    initiative:advancePhase()
  end)
  DecrementPhase       = Button:new("Decrement Phase", 8, 114, function()
    initiative:reversePhase()
  end)
  local green          = hexToRGBA('#37946E')
  local darkgreen      = hexToRGBA('#277052')
  local white          = hexToRGBA('#ffffff')

  IncrementTurn:set('width', 160)
  IncrementTurn:modify({ bg = green, hoverBg = darkgreen, hoverColor = white })
  DecrementTurn:set('width', 160)
  IncrementPhase:set('width', 160)
  IncrementPhase:modify({ bg = green, hoverBg = darkgreen, hoverColor = white })
  DecrementPhase:set('width', 160)
end

-- Scene updates loop
function scene.update(dt)
  IncrementTurn:update(dt)
  DecrementTurn:update(dt)
  IncrementPhase:update(dt)
  DecrementPhase:update(dt)
  GameState.lair:update(dt)
  if EntityManager.registry then
    for _, v in pairs(EntityManager.registry) do
      v:update(dt)
    end
  end
end

-- Scene draw loop
function scene.draw()
  GameState.lair:draw()
  GameState:draw()
  if EntityManager.registry then
    for _, v in pairs(EntityManager.registry) do
      v:draw()
    end
  end
  IncrementTurn:draw()
  DecrementTurn:draw()
  IncrementPhase:draw()
  DecrementPhase:draw()
end

return scene
