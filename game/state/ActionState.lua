local ActionState = {}
ActionState.__index = ActionState

ActionState.debug = Debug
ActionState.debugLabel = LogManagerColor.colorf('{yellow}[ActionState]{reset}')

function ActionState:new()
end

function ActionState:next()
end

function ActionState:prev()
end

function ActionState:play()
end

return ActionState
