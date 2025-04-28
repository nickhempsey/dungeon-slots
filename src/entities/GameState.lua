GameState = {}
GameState.__index = GameState

GameState.debug = Debug

GameState.scenes = {
  shop = 'shop',
  menu = 'menu',
  title = 'title',
  event = 'event',
  combat = 'combat',
  inventory = 'inventory'
}


GameState.scene = nil
GameState.currentFloor = 1
GameState.player = nil
GameState.enemies = {}
GameState.currentTurn = nil
GameState.reel = nil
GameState.spinTokens = 3
GameState.inventory = {}

GameState.rng = love.math.newRandomGenerator(os.time())


function GameState:load()
  SceneManager.setPath("scenes/")
  SceneManager.removeAll()

  -- Eventually run "load" for now we'll hard code a default GameState
  GameState.scene = GameState.scenes.combat
  GameState.player = Player:new("Warrior")
  GameState.reel = Reel:new(self.player:getBaseSymbols())

  SceneManager.add("debug")
  SceneManager.add(self.scene)

  SceneManager.modify("debug", { visible = false })

  EventBusManager:publish('load_game', self);
  EventBusManager:publish('current_scene', self.scene);
end

function GameState:update(dt)
end

function GameState:draw()
end

function GameState:generateEnemies()
end

function GameState:loadPlayer()
end

function GameState:savePlayer()
end

return GameState
