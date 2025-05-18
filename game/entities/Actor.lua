local tableMerge = require "utils.tableMerge"

-- Super Class that is used by Actores and Enemies
local Actor = {}
Actor.__index = Actor

Actor.debug = Debug
Actor.debugLabel = LogManagerColor.colorf('{green}[Actor]{reset}')


--- Creates a new Actor (Enemy or Actor) by using the ManifestManager
--- to collect all of the requested data from the model.
---
---@param actorType string The directory inside `./data` that leads to the actors manifest. Actor | Enemy
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
        uid              = 0,
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

function Actor:load()
    if self.preLoad then self:preLoad() end

    self:subscribeToEvents()

    if self.postLoad then self:postLoad() end
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

function Actor:subscribeToEvents()
    EventBusManager:subscribe(
        'initiative_change_turn',
        Actor.onInitiativeTurnChange,
        self,
        10,
        self
    )
    EventBusManager:subscribe(
        'initiative_change_round',
        Actor.onInitiativeRoundChange,
        self,
        10,
        self
    )
    EventBusManager:subscribe(
        'phase_change',
        Actor.onPhaseChange,
        self,
        10,
        self
    )
end

function Actor:onInitiativeTurnChange(data)
    if data.actor.uid == self.uid then
        self.isTurn = true
        self:setAnimation('attack')
        local newPhase = PhaseState:new(PhaseState.types.RESOLVE_STATUS)
        self.phaseState = newPhase

        if self.turnStart then
            self:turnStart(data)
        end
    else
        self:setAnimation('idle')
        self.isTurn = false
        if self.turnEnd then
            self:turnEnd(data)
        end
    end
end

function Actor:onInitiativeRoundChange(data)
    if data.actor.uid == self.uid then
        -- TODO: Increase ante, augment with class abilities.
    end
end

function Actor:onPhaseChange(data)
    if self.isTurn then
        self:phaseStart(data)
    end
end

function Actor:cleanUpEvents()
    -- TODO: as we create listeners drop them at specific times of in the statemanager
end

return Actor
