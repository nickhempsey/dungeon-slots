local tableMerge = require "utils.tableMerge"

local InitiativeState = {}
InitiativeState.__index = InitiativeState

InitiativeState.debug = Debug
InitiativeState.debugLabel = LogManagerColor.colorf('{yellow}[InitiativeState]{reset}')

function InitiativeState:new(savedState)
    local instance = savedState or {
        actor       = 0,
        order       = {},
        prev        = nil,
        next        = nil,
        curr        = nil,
        round       = 0,
        prevRound   = 0,
        roundChange = false,
    }

    setmetatable(instance, InitiativeState)

    return instance
end

--- Rolls initiative for all entities and sorts them in descending order.
--- Each entity's initiative is determined by rolling a d20 and adding their base initiative stat.
--- The results are stored in `self.order` as an array of {uid, initiative} tables, sorted from highest to lowest initiative.
--- Also updates each entity's `rolledInitiative` stat.
---
--- @function InitiativeState:roll
--- @usage InitiativeState:roll()
--- @sideeffect Modifies self.order and each entity's `rolledInitiative` stat.
--- @error Asserts if entities cannot be retrieved from EntityManager.
function InitiativeState:roll()
    local entities = EntityManager.getAll()
    assert(entities, "InitiativeState.roll, 'entities' must exist.")
    self.order = {}

    for uid, v in pairs(entities) do
        local dieRoll = love.math.random(1, 20)
        local baseInitiative = v.stats.initiative
        local total = math.floor(dieRoll + baseInitiative)

        v.stats.rolledInitiative = total -- store rolled initiative separately
        table.insert(self.order, { uid = uid, initiative = total })

        if self.debug then
            LogManager.info(string.format(
                "%s %s uid: %d dieRoll: %d baseInitiative: %d total: %d",
                InitiativeState.debugLabel, v.name, uid, dieRoll, baseInitiative, total
            ))
        end
    end

    table.sort(self.order, function(a, b)
        return (a.initiative or 0) > (b.initiative or 0)
    end)

    if self.debug then
        LogManager.info(string.format("%s initiative rolled", InitiativeState.debugLabel))
    end
end

--- Advances the initiative tracker to the next entity in the initiative order.
--- Updates `prev`, `curr`, `next`, and 'round' indices,
--- wrapping around to the start of the order when the end is reached.
---
--- @function InitiativeState:advance
--- @usage InitiativeState:increment()
--- @sideeffect Modifies self.prev, self.curr, self.next, self.round.
function InitiativeState:increment()
    if self.curr == nil then
        self.prev        = #self.order
        self.curr        = 1
        self.next        = 2
        self.round       = 0
        self.roundChange = true
    elseif self.curr == #self.order then
        self.prev        = #self.order
        self.curr        = 1
        self.next        = 2
        self.prevRound   = self.round
        self.round       = self.round + 1
        self.roundChange = true
    else
        self.prev = self.prev + 1
        self.curr = self.curr + 1
        self.next = self.next + 1
        self.roundChange = false
    end

    if self.debug then
        LogManager.info(string.format("%s Initiative updated.", InitiativeState.debugLabel))
        LogManager.info({
            prev = self.prev,
            next = self.next,
            curr = self.curr
        })
    end
end

--- Reverses the initiative tracker to the previous entity in the initiative order.
--- Updates `prev`, `curr`, `next`, and 'round' indices,
--- wrapping around to the end of the order when the start is reached.
---
--- @function InitiativeState:advance
--- @usage InitiativeState:increment()
--- @sideeffect Modifies self.prev, self.curr, self.next
function InitiativeState:decrement()
    if self.curr == 1 then
        self.curr = #self.order
        self.next = self.curr - 1
        self.prev = self.curr
    else
        self.curr = self.curr - 1
        self.next = self.next - 1
        self.prev = self.prev - 1
    end

    if self.debug then
        LogManager.info(string.format("%s Initiative updated.", InitiativeState.debugLabel))
        LogManager.info({
            prev = self.prev,
            next = self.next,
            curr = self.curr
        })
    end
end

--- Retrieves the entity (actor) for the current initiative turn.
--- Asserts that the current initiative index is set and that the initiative order is not empty.
--- Returns the entity corresponding to the current initiative, or nil if not found.
---
---@function InitiativeState:getActorForCurrent
---@treturn table|nil The entity for the current initiative, or nil if not found.
---@error Asserts if curr is nil or order is empty.
function InitiativeState:getActorForCurrent()
    assert(self.curr ~= nil,
        "InitiativeState:getActorForCurrent: 'curr' cannot be nil")
    assert(#self.order > 0,
        "InitiativeState:getActorForCurrent: 'order' does not have items")

    local entry = self.order[self.curr]
    if entry then
        local entity = EntityManager.get(entry.uid)
        return entity
    end
    return nil
end

function InitiativeState:advanceInitiative()
    assert(#self.order > 0,
        "InitiativeState:getActorForCurrent: 'order' does not have items")

    -- Setup the next actor
    self:increment()
    self.actor = self:getActorForCurrent()

    self:publishEvents()
end

function InitiativeState:reverseInitiative()
    assert(#self.order > 0,
        "InitiativeState:getActorForCurrent: 'order' does not have items")

    -- Setup the next actor
    self:decrement()
    self.actor = self:getActorForCurrent()

    self:publishEvents()
end

function InitiativeState:advancePhase()
    local newPhase = self.actor.phaseState:increment()
    if newPhase then
        self.actor.phaseState = newPhase
    end
end

function InitiativeState:reversePhase()
    local newPhase = self.actor.phaseState:decrement()
    if newPhase then
        self.actor.phaseState = newPhase
    end
end

function InitiativeState:publishEvents(eventId)
    local data = {
        roundChange = self.roundChange,
        prevRound = self.prevRound,
        round = self.round,
        prev = self.prev,
        next = self.next,
        curr = self.curr,
        actor = {
            id = self.actor.id,
            uid = self.actor.uid,
        }
    }

    EventBusManager:publish('initiative_change_turn', data)
    if self.roundChange then
        EventBusManager:publish('initiative_change_round', data)
    end
end

return InitiativeState
