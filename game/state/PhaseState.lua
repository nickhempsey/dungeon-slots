local readonly = require "utils.readonly"
local tableMerge = require "utils.tableMerge"

local PhaseState = {}
PhaseState.__index = PhaseState

PhaseState.debug = Debug
PhaseState.debugLabel = LogManagerColor.colorf('{yellow}[PhaseState]{reset}')


local TYPES = readonly({
    RESOLVE_STATUS = {
        id = 'RESOLVE_STATUS',
        name = 'Resolve status effects.',
        prev = false,
        next = 'UPGRADE_1',
    },
    UPGRADE_1      = {
        id = 'UPGRADE_1',
        name = 'Upgrade/maintain your symbols and abilities.',
        prev = 'RESOLVE_STATUS',
        next = 'ROLL',
    },
    ROLL           = {
        id = 'ROLL',
        name = 'Roll your slot machine.',
        prev = 'UPGRADE_1',
        next = 'MAIN',
    },
    MAIN           = {
        id = 'MAIN',
        name = 'Play your abilities.',
        prev = 'ROLL',
        next = 'UPGRADE_2',
    },
    UPGRADE_2      = {
        id = 'UPGRADE_2',
        name = 'Upgrade/maintain your symbols and abilities.',
        next = 'END',
        prev = 'MAIN'
    },
    END            = {
        id = 'END',
        name = 'End your turn and move to the next actor.',
        prev = 'UPGRADE',
        next = false,
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
        local nextPhaseKey = self.types[self.next]
        local newPhase = PhaseState:new(nextPhaseKey)
        EventBusManager:publish('phase_change', newPhase)
        return newPhase
    else
        GameState.initiative:advanceInitiative()
        return nil
    end
end

function PhaseState:decrement()
    if self.prev then
        local prevPhaseKey = self.types[self.next]
        local newPhase = PhaseState:new(prevPhaseKey)
        EventBusManager:publish('phase_change', prevPhaseKey)
        return newPhase
    else
        GameState.initiative:reverseInitiative()
        return nil
    end
end

return PhaseState
