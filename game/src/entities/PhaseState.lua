-- PhaseState.lua
local PhaseState = {}
function PhaseState:new(phaseType)
    return {
        phaseType = phaseType, -- "RESOLVE_STATUS","ROLL","MAIN","UPGRADE","END"
        isComplete = false,
    }
end

return PhaseState
