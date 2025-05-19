local pathDefined = require "utils.pathDefined"

local CursorManager = {}
CursorManager.__index = CursorManager

CursorManager.debug = Debug
CursorManager.debugLabel = LogManagerColor.colorf("{red}[CursorManager]{reset}")


CursorManager.default = nil
CursorManager.current = nil
CursorManager.previous = nil
CursorManager.registry = {}


function CursorManager.load()
    -- Hide the system cursor
    love.mouse.setVisible(false)

    -- Register the cursors
    CursorManager.register('assets/images/cursors/cursor.png', 'default')
    CursorManager.register('assets/images/cursors/cursor_debug.png', 'debug')
    CursorManager.setCurrent('default')
    CursorManager.default = CursorManager.current
end

function CursorManager.register(imagePath, explicitId)
    assert(pathDefined(imagePath), "CursorManager.register, 'imagePath' not defined")

    local cursor = {
        image = love.graphics.newImage(imagePath),
        id = explicitId,
    }
    CursorManager.registry[explicitId] = cursor

    if CursorManager.debug then
        LogManager.info(string.format("%s added new cursor: %s", CursorManager.debugLabel, explicitId))
    end

    return cursor
end

function CursorManager.setCurrent(id)
    if not CursorManager.hasCursor(id) then return end

    local cursor = CursorManager.get(id)
    CursorManager.previous = CursorManager.current
    CursorManager.current = cursor
end

function CursorManager.setPrevious()
    CursorManager.current = CursorManager.previous
end

function CursorManager.get(id)
    if not CursorManager.hasCursor(id) then return end

    return CursorManager.registry[id]
end

function CursorManager.hasCursor(id)
    if not id then return false end

    if CursorManager.registry[id] then
        return true
    end
    return false
end

function CursorManager.update(dt)
end

function CursorManager.draw()
    if not CursorManager.current then return end


    local mx, my = ViewportManager:getMousePosition()
    -- TODO: Need a positioning method.
    local qx, qy = math.floor(mx - CursorManager.current.image:getWidth() / 2) + 1,
        math.floor(my - CursorManager.current.image:getHeight() / 2) + 1

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(CursorManager.current.image, qx, qy)
end

function CursorManager:set(flag, value)
    self[flag] = value
end

return CursorManager
