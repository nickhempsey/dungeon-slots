local GameState = {}
GameState.__index = GameState

GameState.debug = Debug
GameState.debugLabel = LogManagerColor.colorf('{green}[GameState]{reset}')

GameState.scenes = {
  shop = 'shop',
  menu = 'menu',
  intro = 'intro',
  title = 'title',
  event = 'event',
  combat = 'combat',
  inventory = 'inventory'
}

GameState.scene = nil
GameState.currentFloor = 1
GameState.currentTurn = nil

GameState.hero = nil
GameState.inventory = {}

GameState.enemies = {}

GameState.reel = nil
GameState.spinTokens = 3

GameState.rng = love.math.newRandomGenerator(os.time())

function GameState:load()
  SceneManager.setPath("src/scenes/")
  SceneManager.removeAll()
  SceneManager.add("debug")

  -- Eventually run "load" for now we'll hard code a default GameState
  GameState.scene = GameState.scenes.intro
  GameState.hero = Hero:new('luck_punk')
  GameState.reel = Reel:new(GameState.hero:getBaseSymbols())

  SceneManager.add(GameState.scene)

  EventBusManager:publish('load_game');
  EventBusManager:publish('current_scene', GameState.scene);
end

function GameState:update(dt)

end

function GameState:draw()

end

---@param quantity number
---@param level string - future implementation
function GameState:generateEnemies(quantity, level)
  assert(quantity, "Function 'generateEnemies': parameter 'quantity' must be a number.")

  local enemies = {}

  local y = 48;
  local x = 400;
  for i = 1, quantity do
    local id = 'change_goblin'
    if i > 2 then
      id = 'change_ogre'
    end

    local enemy = Enemy:new(id)
    enemy.x = x
    enemy.y = y
    x = x + enemy.w
    table.insert(enemies, enemy)
  end

  self.enemies = enemies
  if self.debug then
    LogManager.info(string.format("%s %d new enemies created", self.debugLabel, quantity))
    -- LogManager.info(enemies)
  end
end

return GameState
