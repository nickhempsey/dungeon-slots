local StatusEffect = {}

function StatusEffect:new(name, isPositive, duration, triggerPhase)
    return {
        name         = name,
        isPositive   = isPositive,
        duration     = duration,
        triggerPhase = triggerPhase, -- e.g. "RESOLVE_START"
    }
end

return StatusEffect
