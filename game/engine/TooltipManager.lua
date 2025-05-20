local TooltipManager      = {}
TooltipManager.debug      = Debug
TooltipManager.debugLabel = LogManagerColor.colorf("{red}[TooltipManager]{reset}")

TooltipManager.nextId     = 1
TooltipManager.registry   = {}


function TooltipManager.register(tooltip, explicitId)
    if tooltip.uid ~= nil then
        return
    end

    local uid = explicitId or TooltipManager.nextId
    tooltip:set('uid', uid)
    TooltipManager.registry[uid] = tooltip

    -- bump nextId if we used it, or if explicitId >= nextId
    if explicitId then
        assert(type(explicitId) == "number", "TooltipManager.register, 'explicitId' must be a number.")
        TooltipManager.nextId = math.max(TooltipManager.nextId, explicitId + 1)
    else
        TooltipManager.nextId = TooltipManager.nextId + 1
    end

    if TooltipManager.debug then
        LogManager.info(string.format("%s added tooltip with id %d", TooltipManager.debugLabel, uid))
    end

    return uid
end

-- Unregister/destroy an entity (should only happen after all effects and animations have been completed)
---
---@param uid number
---@return  boolean confirmation A confirmation that the entity was removed from the registry.
function TooltipManager.unregister(uid)
    if TooltipManager.registry[uid] then
        TooltipManager.registry[uid] = nil
        return true
    end
    return false
end

-- Lookup by ID
function TooltipManager.get(uid)
    assert(type(uid) == 'number', "TooltipManager.get, 'uid' must be a number")
    local entity = TooltipManager.registry[uid]

    assert(entity, string.format("TooltipManager.get, failed to retrieve entity %s", uid))
    return entity
end

function TooltipManager.getAll()
    return TooltipManager.registry
end

function TooltipManager.update(dt)
    local tooltips = TooltipManager.getAll()
    for _, v in pairs(tooltips) do
        v:update(dt)
    end
end

function TooltipManager.draw()
    local tooltips = TooltipManager.getAll()
    for _, v in pairs(tooltips) do
        v:draw()
    end
end

function TooltipManager.debugPositions()
    local left_top = Tooltip:new('Left Top', 'left', 100, 76, 'left', 'top')
    local left_center = Tooltip:new('Left Center', 'left', 100, 76, 'left', 'center')
    local left_bottom = Tooltip:new('Left Bottom', 'left', 100, 76, 'left', 'bottom')
    left_top:set('debugSummary', true)
    left_center:set('debugSummary', true)
    left_bottom:set('debugSummary', true)

    local right_top = Tooltip:new('Right Top', 'left', 100, 76, 'right', 'top')
    local right_center = Tooltip:new('Right Center', 'left', 100, 76, 'right', 'center')
    local right_bottom = Tooltip:new('Right Bottom', 'left', 100, 76, 'right', 'bottom')
    right_top:set('debugSummary', true)
    right_center:set('debugSummary', true)
    right_bottom:set('debugSummary', true)


    local center_top = Tooltip:new('Center Top', 'left', 100, 76, 'center', 'top')
    -- center_center:set('debugSummary', true)
    local center_bottom = Tooltip:new('Center Bottom', 'left', 100, 76, 'center', 'bottom')
    center_top:set('debugSummary', true)
    -- local center_center = Tooltip:new('Center Center', 'left', 100, 76, 'center', 'center')
    center_bottom:set('debugSummary', true)
end

return TooltipManager

--- Examples:
