local tableMerge = require "utils.tableMerge"

local Lair = {}
Lair.__index = Lair

Lair.debug = Debug
Lair.debugLabel = LogManagerColor.colorf('{cyan}[Lair]{reset}')

-- Instantiate a new Lair by their id.
--
---@param id string
function Lair:new(id)
    assert(type(id) == "string", "Function 'new': parameter 'id' must be a string.")
    local manifest = ManifestManager.loadEntityManifest("lairs", id)
    if not manifest then
        return nil
    end

    local entity = setmetatable(tableMerge.deepMergeWithArray({
        someThing = 2
    }, manifest), Lair)

    return entity
end

-- Runs in love.load
function Lair:load()
end

function Lair:update(dt)
end

function Lair:draw()
end

function Lair:getGeneratedEnemies()
    return self.generatedEnemies
end

function Lair:generateEnemies()
    local quantity = self:roll('quantityOfEnemies')
    local availableEnemies = self.availableEnemies

    LogManager.info(quantity, availableEnemies)

    assert(quantity, "Function 'generateEnemies': parameter 'quantity' must be a number.")
    assert(availableEnemies, "Function 'generateEnemies': parameter 'available' must be a table.")

    local enemies = {}

    local y = 48;
    local x = 400;
    for i = 1, quantity do
        local randomIndex = love.math.random(1, #availableEnemies)
        local randomEnemyId = availableEnemies[randomIndex]
        LogManager.info(randomIndex)
        LogManager.info(randomEnemyId)
        LogManager.info(availableEnemies)

        local enemy = Enemy:new(randomEnemyId)
        enemy.x = x
        enemy.y = y
        x = x + enemy.w
        table.insert(enemies, enemy)
    end

    self.generatedEnemies = enemies
    if self.debug then
        LogManager.info(string.format("%s %d new enemies created", self.debugLabel, quantity))
        -- LogManager.info(enemies)
    end
end

return Lair
