local tableMerge = require "utils.tableMerge"

-- Super Class that is used by Heroes and Enemies
local Actor = {}
Actor.__index = Actor

Actor.debug = Debug
Actor.debugLabel = LogManagerColor.colorf('{green}[Actor]{reset}')


--- Creates a new Actor (Enemy or Hero) by using the ManifestManager
--- to collect all of the requested data from the model.
---
---@param actorType string The directory inside `./data` that leads to the actors manifest. Hero | Enemy
---@param actorId string The directory name for this actor, ie: `luck_punk` | `change_goblin`
---@return table|nil Actor
function Actor:new(actorType, actorId)
    assert(type(actorId) == "string", "Function 'new': parameter 'actorId' must be a string.")
    assert(type(actorType) == "string", "Function 'new': parameter 'actorType' must be a string.")

    local manifest = ManifestManager.loadEntityManifest(actorType, actorId)
    if not manifest then
        return nil
    end

    local instance = setmetatable(tableMerge.deepMergeWithArray({
        x                = 0,
        y                = 0,
        ox               = 0,
        oy               = 0,
        actorType        = actorType,
        currentAnimation = nil,
        currentSprite    = nil,
        phaseState       = {},
        statusEffects    = {},
        symbolBank       = {},
        InitiativeState  = nil,
    }, manifest), self)

    -- Set idle sprite
    if instance.assets.images.sprite then
        instance.currentSprite = instance.assets.images.sprite

        assert(instance.assets.images.sprite.animations,
            "Actors must have a default 'idle' animation with a base idle animaton.")
        instance.currentAnimation = instance.assets.images.sprite.animations.factory('idle')
    end

    return instance
end

--- Modifies properties on the table
---
---@param flags table
function Actor:modify(flags)
    if flags then
        for key, value in pairs(flags) do
            self[key] = value
        end

        if self.debug then
            LogManager.info(string.format("%s modified flags for '%s'", self.debugLabel, self.id))
            LogManager.info(flags)
        end
    end
end

--- Set the sprite of the actor
---
---@param sprite string
function Actor:setSprite(sprite)
    if self.currentSprite then
        self.currentSprite = self.assets.images[sprite]
    end
end

--- Set a specific animation
---
---@param tag string
function Actor:setAnimation(tag)
    LogManager.info(string.format("%s animation change: %s %s", self.debugLabel, self.name, tag))
    LogManager.info(self.currentSprite)
    if self.currentAnimation and self.currentSprite.animations then
        self.currentAnimation = self.currentSprite.animations.factory(tag)
    end
end

return Actor
