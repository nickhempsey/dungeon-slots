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
        currentBackground = nil,
        stageSet = false
    }, manifest), Lair)

    if entity.assets.images.bg then
        entity.currentBackground = entity.assets.images.bg.image
    end


    return entity
end

-- Runs in love.load
function Lair:load()
end

function Lair:update(dt)
end

function Lair:draw()
    if self.currentBackground then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.currentBackground, 0, 0)
    end
end

function Lair:setStage()
    self:generateEnemies()

    local midX = ViewportManager:getMidScreen()
    GameState.hero:modify({ x = midX - 64, y = self.floorLevel })

    if self.generatedEnemies then
        self.stageSet = true
    end
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

    local midX = ViewportManager:getMidScreen()
    midX = midX + 64
    for i = 1, quantity do
        local randomIndex = love.math.random(1, #availableEnemies)
        local randomEnemyId = availableEnemies[randomIndex]

        local enemy = Enemy:new(randomEnemyId)
        if enemy then
            enemy.x = midX
            enemy.y = self.floorLevel
            midX = midX + enemy.w
            table.insert(enemies, enemy)
        end
    end

    self.generatedEnemies = enemies
    if self.debug then
        LogManager.info(string.format("%s %d new enemies created", self.debugLabel, quantity))
    end
end

return Lair
