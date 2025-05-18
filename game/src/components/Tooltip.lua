local hexToRGBA = require "utils.hexToRGBA"
local unpack = require "utils.unpack"

local Tooltip = {}
Tooltip.__index = Tooltip

Tooltip.debug = Debug
Tooltip.debugLabel = LogManagerColor.colorf("{blue}[Tooltip]{reset}")

--- Generate a new tooltip that will follow the mouse around screen.
---
---@param content string
---@param content_pos 'left'|'center'|'right'|nil
---@param width number|nil
---@param height number|nil
---@param mouse_rel_x 'left'|'center'|'right'|nil
---@param mouse_rel_y 'top'|'center'|'bottom'|nil
---@param curser_buffer number|nil
---@param bg table|nil hexToRGBA
---@param color table|nil hexToRGBA
---@param border_radius number|nil
---@param border_color table|nil hexToRGBA
---@param viewport_buffer number|nil
---@return metatable
function Tooltip:new(
    content, content_pos,
    width, height,
    mouse_rel_x, mouse_rel_y,
    curser_buffer,
    bg, color,
    border_radius, border_color,
    viewport_buffer)
    local instance = {
        uid             = nil,

        x               = 0,
        y               = 0,

        h               = height or 18,
        w               = width or 90,

        ox              = 0,
        oy              = 0,

        x_center        = 0,
        y_center        = 0,

        bg              = bg or { '#fff', 0.7 },
        color           = color or { '#000', 1 },
        border_radius   = border_radius or 3,
        border_color    = border_color or { '#000', 1 },

        mouse_rel_x     = mouse_rel_x or 'center', -- left | center | right
        mouse_rel_y     = mouse_rel_y or 'top',    -- top | center | bottom
        cursor_w        = GameState.cursor:getWidth() / 2,
        cursor_h        = GameState.cursor:getHeight() / 2,
        cursor_buffer   = curser_buffer or 4,

        viewport_buffer = viewport_buffer or 8,

        content         = content or 'tooltip',
        content_pos     = content_pos or 'center', -- left | center | right
        content_oy      = 4,
        content_ox      = 4
    }


    setmetatable(instance, Tooltip)

    instance.uid = TooltipManager.register(instance)

    if Tooltip.debug then
        LogManager.info(string.format("%s new Tooltip", Tooltip.debugLabel))
    end
    return instance
end

function Tooltip:update(dt)
    self:postionRelativeToMouse()

    -- Normalize the xy to the pixel grid
    self.adjusted_x = self.x + self.ox
    self.adjusted_y = self.y + self.oy
    self:handleHandleEdgeDetection()

    self.adjusted_x = math.floor(self.adjusted_x)
    self.adjusted_y = math.floor(self.adjusted_y)
end

function Tooltip:postionRelativeToMouse()
    local mouse_x, mouse_y = ViewportManager:getMousePosition()

    ------------------
    --- HORIZONTAL ---
    ------------------
    self.x = mouse_x
    if self.mouse_rel_x == 'left' then
        self.ox = -(self.w + self.cursor_w + self.cursor_buffer)
    end
    if self.mouse_rel_x == 'center' then
        self.ox = -(self.w / 2)
    end
    if self.mouse_rel_x == 'right' then
        self.ox = self.cursor_w + self.cursor_buffer
    end

    ----------------
    --- VERTICAL ---
    ----------------
    self.y = mouse_y
    if self.mouse_rel_y == 'center' then
        self.oy = -(self.h / 2)
    end
    if self.mouse_rel_y == 'top' then
        self.oy = -(self.h + self.cursor_h + self.cursor_buffer)
    end
    if self.mouse_rel_y == 'bottom' then
        self.oy = self.cursor_h + self.cursor_buffer
    end
end

function Tooltip:handleHandleEdgeDetection()
    local vp_x, vp_y = ViewportManager:getDimensions()
    ----------------
    --- VERTICAL ---
    ----------------
    --- TOP
    if self.adjusted_y <= self.viewport_buffer then
        self.adjusted_y = self.viewport_buffer
    end
    --- BOTTOM
    if self.adjusted_y + self.h >= vp_y - self.viewport_buffer then
        self.adjusted_y = vp_y - (self.viewport_buffer + self.h)
    end
    ------------------
    --- HORIZONTAL ---
    ------------------
    --- LEFT
    if self.adjusted_x <= self.viewport_buffer then
        self.adjusted_x = self.viewport_buffer
    end
    --- RIGHT
    if self.adjusted_x + self.w >= vp_x - self.viewport_buffer then
        self.adjusted_x = vp_x - (self.viewport_buffer + self.w)
    end
end

function Tooltip:draw()
    ------------------
    --- BACKGROUND ---
    ------------------
    love.graphics.setColor(hexToRGBA(unpack(self.bg)))
    love.graphics.rectangle("fill",
        self.adjusted_x,
        self.adjusted_y,
        self.w,
        self.h,
        self.border_radius,
        self.border_radius)

    --------------
    --- BORDER ---
    --------------
    love.graphics.setColor(hexToRGBA(unpack(self.border_color)))
    love.graphics.rectangle("line",
        self.adjusted_x,
        self.adjusted_y,
        self.w,
        self.h,
        self.border_radius,
        self.border_radius)

    ---------------
    --- CONTENT ---
    ---------------
    FontsManager:setFontBMP('sm', 'Medium')
    love.graphics.setColor(hexToRGBA(unpack(self.color)))
    --[[
        local debugText = string.format([[
            %s
            x: %d   y: %d
            ox: %d  oy: %d
            ax: %d  ay: %d
            w: %d   h: %d
            cw: %d  ch: %d
            ]]
    --[[, -- remove the comment and keep the comma
            self.content,
            self.x,
            self.y,
            self.ox,
            self.oy,
            self.adjusted_x,
            self.adjusted_y,
            self.w,
            self.h,
            self.cursor_w,
            self.cursor_h)
    ---]]
    love.graphics.printf(self.content,
        math.floor(self.adjusted_x + self.content_ox),
        math.floor(self.adjusted_y + self.content_oy),
        math.floor(self.w - self.content_ox * 2),
        self.content_pos)
end

function Tooltip:set(flag, value)
    self[flag] = value
end

function Tooltip:getUID(flag)
    return self[flag]
end

return Tooltip
