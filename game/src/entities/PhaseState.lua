local readonly = require "utils.readonly"
local tableMerge = require "utils.tableMerge"

local PhaseState = {}
PhaseState.__index = PhaseState

local TYPES = readonly({
    RESOLVE_STATUS = {
        id = 'RESOLVE_STATUS',
        name = 'Resolve status effects.',
        next = 'ROLL',
        prev = false
    },
    ROLL           = {
        id = 'ROLL',
        name = 'Roll your slot machine.',
        next = 'MAIN',
        prev = 'RESOLVE_STATUS'
    },
    MAIN           = {
        id = 'MAIN',
        name = 'Play your abilities.',
        next = 'UPGRADE',
        prev = 'ROLL'
    },
    UPGRADE        = {
        id = 'UPGRADE',
        name = 'Upgrade your symbols on abilities.',
        next = 'END',
        prev = 'MAIN'
    },
    END            = {
        id = 'END',
        name = 'End your turn and move to the next actor.',
        next = false,
        prev = 'UPGRADE'
    },
})

PhaseState.types = TYPES

--- Creates a new phase state machine.
---
---@param phaseType table TYPES
---@return table
function PhaseState:new(phaseType)
    assert(type(phaseType) == 'table', string.format("phaseType must be a table, received %s", type(phaseType)))

    local instance = tableMerge.deepMergeWithArray(phaseType,
        {
            isComplete = false,
        })

    setmetatable(instance, PhaseState)
    return instance
end

function PhaseState:increment()
    if self.next then
        return PhaseState:new(self.types[self.next])
    else
        GameState.initiative:advanceInitiative()
        return nil
    end
end

function PhaseState:decrement()
    if self.prev then
        return PhaseState:new(self.types[self.prev])
    else
        GameState.initiative:reverseInitiative()
        return nil
    end
end

return PhaseState
