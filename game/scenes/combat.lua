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
  local lairId   = "vault"
  local lair     = Lair:new(lairId)
  GameState.lair = lair
  GameState.lair:setStage()

  EntityManager.load()

  local initiative = InitiativeState:new()
  GameState.initiative = initiative
  GameState.initiative:roll()
  -- temp tick forward to 0 eventually will check for loadmode first.
  GameState.initiative:advanceInitiative()


  -- TEMP START
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
    for k, v in pairs(EntityManager.getAll()) do
      if k > 1 then
        EntityManager.unregister(v.uid)
      end
    end
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

  Spin = Button:new("Spin", 8, 160, function()
    if GameState.hero.reel then
      GameState.hero.reel:spinReel()
    end
  end)
  Spin:set('width', 160)
  -- TEMP END

  scene.x = 338
  scene.y = 254
end

-- Scene updates loop
function scene.update(dt)
  GameState.lair:update(dt)
  EntityManager.update(dt)

  -- TEMP START
  IncrementTurn:update(dt)
  DecrementTurn:update(dt)
  IncrementPhase:update(dt)
  DecrementPhase:update(dt)
  RerollLair:update(dt)
  Spin:update(dt)
  -- TEMP END
end

-- Scene draw loop
function scene.draw()
  GameState.lair:draw()
  EntityManager.draw()


  -- TEMP START
  IncrementTurn:draw()
  DecrementTurn:draw()
  IncrementPhase:draw()
  DecrementPhase:draw()
  RerollLair:draw()
  Spin:draw()

  -- Define the mask shape
  love.graphics.stencil(function()
    love.graphics.rectangle("fill", scene.x, scene.y, 32 * 3 + 20, 91)
  end, "replace", 1)

  -- Only draw where the stencil value is 1
  love.graphics.setStencilTest("equal", 1)
  Reel:drawReel(GameState.hero.reel, GameState.hero.reel.current, scene.x, scene.y, 9, 5)
  love.graphics.setStencilTest() -- Reset


  -- DEBUG RED LINES
  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.setLineWidth(1)
  love.graphics.line(337, 283, 450, 283)
  love.graphics.line(337, 320, 450, 320)
  love.graphics.setColor(1, 1, 1)
  -- TEMP END
end

return scene
