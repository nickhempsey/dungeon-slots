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
  local lairId   = "tutorial_lair"
  local lair     = Lair:new(lairId)
  GameState.lair = lair

  if lair then
    LogManager.info(lair)
    GameState.lair:setStage()

    assert(lair.stageSet, string.format('The stage %s failed to set properly.', lairId))
  end

  local initiative = InitiativeState:new()
  GameState.initiative = initiative
  GameState.initiative:roll()
  -- temp tick forward to 0 eventually will check for loadmode first.
  GameState.initiative:advanceInitiative()


  IncrementTurn   = Button:new("Increment Turn", 8, 48, function()
    GameState.initiative:advanceInitiative()
  end)
  DecrementTurn   = Button:new("Decrement Turn", 8, 68, function()
    GameState.initiative:reverseInitiative()
  end)
  IncrementPhase  = Button:new("Increment Phase", 8, 96, function()
    GameState.initiative:advancePhase()
  end)
  DecrementPhase  = Button:new("Decrement Phase", 8, 114, function()
    GameState.initiative:reversePhase()
  end)
  local green     = hexToRGBA('#37946E')
  local darkgreen = hexToRGBA('#277052')
  local white     = hexToRGBA('#ffffff')

  IncrementTurn:set('width', 160)
  IncrementTurn:modify({ bg = green, hoverBg = darkgreen, hoverColor = white })
  DecrementTurn:set('width', 160)
  IncrementPhase:set('width', 160)
  IncrementPhase:modify({ bg = green, hoverBg = darkgreen, hoverColor = white })
  DecrementPhase:set('width', 160)

  RerollLair = Button:new("Reroll Lair", 8, 140, function()
    for k, v in pairs(EntityManager.registry) do
      if k > 1 then
        EntityManager.unregister(v.uid)
      end
    end
    lairId = "tutorial_lair"
    local newlair = Lair:new(lairId)
    GameState.lair = newlair
    GameState.lair:setStage()

    local newinitiative = InitiativeState:new()
    GameState.initiative = newinitiative
    GameState.initiative:roll()
    -- temp tick forward to 0 eventually will check for loadmode first.
    GameState.initiative:advanceInitiative()
  end)
  RerollLair:set('width', 160)
end

-- Scene updates loop
function scene.update(dt)
  IncrementTurn:update(dt)
  DecrementTurn:update(dt)
  IncrementPhase:update(dt)
  DecrementPhase:update(dt)
  RerollLair:update(dt)
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
  if EntityManager.getAll() then
    for _, v in pairs(EntityManager.getAll()) do
      v:draw()
      love.graphics.setColor(hexToRGBA('#fff', 0.8))
      love.graphics.rectangle("fill", v.x - 16, v.y + 5, 32, 15, 4, 4)
      love.graphics.setColor(hexToRGBA('#000', 1))
      love.graphics.rectangle("line", v.x - 16, v.y + 5, 32, 15, 4, 4)
      FontsManager:setFontBMP('sm', 'Medium')
      love.graphics.setColor(hexToRGBA('#000', 1))
      love.graphics.printf(string.format("I: %s", v.stats.rolledInitiative), v.x - 16, v.y + 9, 32, "center")

      -- reset tint for next sprite
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
  IncrementTurn:draw()
  DecrementTurn:draw()
  IncrementPhase:draw()
  DecrementPhase:draw()
  RerollLair:draw()
end

return scene
