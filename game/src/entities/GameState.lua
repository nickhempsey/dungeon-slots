-- GameState will be used to managed top level state and interface with the scenes.

local GameState = {}
GameState.__index = GameState

GameState.debug = Debug
GameState.debugLabel = LogManagerColor.colorf('{green}[GameState]{reset}')

GameState.scenes = {
  SHOP      = 'shop',
  MENU      = 'menu',
  INTRO     = 'intro',
  TITLE     = 'title',
  EVENT     = 'event',
  COMBAT    = 'combat',
  INVENTORY = 'inventory'
}

GameState.scene = nil
GameState.heroId = 1
GameState.initiative = {}
GameState.lair = nil
GameState.actor = nil

GameState.rng = love.math.newRandomGenerator(os.time())

function GameState:load()
  SceneManager.setPath("src/scenes/")
  SceneManager.removeAll()
  SceneManager.add("debug")

  -- Eventually run "load" for now we'll hard code a default GameState
  GameState.scene = GameState.scenes.INTRO
  GameState.hero = Hero:new('luck_punk')

  SceneManager.add(GameState.scene)

  EventBusManager:publish('load_game');
  EventBusManager:publish('current_scene', GameState.scene);
end

function GameState:update(dt)

end

function GameState:draw()

end

function GameState.resetRNG()
  -- Clear out the system cache.
  love.math.setRandomSeed(os.time())
  love.math.random()
  love.math.random()
  love.math.random()
end

return GameState
