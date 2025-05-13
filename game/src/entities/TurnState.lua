-- TurnState.lua
local TurnState = {}
function TurnState:new(roundNumber, actor)
    return {
        roundNumber = roundNumber,
        actor       = actor, -- reference to an Actor
        phaseStates = {}, -- list of PhaseState
    }
end

return TurnState
