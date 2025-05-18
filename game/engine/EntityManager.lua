local hexToRGBA          = require "utils.hexToRGBA"

local EntityManager      = {}
EntityManager.debug      = Debug
EntityManager.debugLabel = LogManagerColor.colorf("{green}[EntityManager]{reset}")

EntityManager.nextId     = 1
EntityManager.registry   = {} -- [uid] = entity

--- Register a brand‐new entity, or re‐register on load
---
---@param entity table
---@param explicitId any
---@return number
function EntityManager.register(entity, explicitId)
    assert(type(entity) == 'table', "EntityManager.register, 'entity' must be a table")
    local uid = explicitId or EntityManager.nextId
    entity.uid = uid
    EntityManager.registry[uid] = entity

    -- bump nextId if we used it, or if explicitId >= nextId
    if explicitId then
        assert(type(explicitId) == "number", "EntityManager.register, 'explicitId' must be a number.")
        EntityManager.nextId = math.max(EntityManager.nextId, explicitId + 1)
    else
        EntityManager.nextId = EntityManager.nextId + 1
    end

    LogManager.info(string.format("%s added entity: %s with id %d", EntityManager.debugLabel, entity.id, uid))

    return uid
end

-- Unregister/destroy an entity (should only happen after all effects and animations have been completed)
---
---@param uid number
---@return  boolean confirmation A confirmation that the entity was removed from the registry.
function EntityManager.unregister(uid)
    local entity = EntityManager.get(uid)

    -- if entity.dead and entity.animationsComplete then
    EntityManager.registry[uid] = nil
    return true
    -- end
    -- return false
end

-- Lookup by ID
function EntityManager.get(uid)
    assert(type(uid) == 'number', "EntityManager.get, 'id' must be a number")
    local entity = EntityManager.registry[uid]

    assert(entity, string.format("EntityManager.get, failed to retrieve entity %s", uid))
    return entity
end

function EntityManager.getAll()
    return EntityManager.registry
end

function EntityManager.load()
    if EntityManager.getAll() then
        for _, v in pairs(EntityManager.getAll()) do
            if v.load then
                v:load()
            end
        end
    end
end

function EntityManager.update(dt)
    if EntityManager.getAll() then
        for _, v in pairs(EntityManager.getAll()) do
            v:update(dt)
        end
    end
end

function EntityManager.draw()
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
end

return EntityManager
