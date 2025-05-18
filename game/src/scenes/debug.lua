local hexToRGBA = require "utils.hexToRGBA"
local cur = SceneManager.current
local scene = {}
scene.zsort = 100000
scene.drawOverlay = false
scene.overlay_image = nil
scene.activeModifers = {}

local grid_overlay_image = love.graphics.newImage("assets/images/grid_overlay.png")
-- local debugCursorHeight = 31
-- local debugCursorImageData = love.image.newImageData("assets/images/cursor_debug.png")
-- local debugCursor = love.mouse.newCursor(debugCursorImageData, 15, 15)


-- Stacking Scene Manager can be used to call a scenes modify function.
-- The modify function is intended to be used for changing specific
-- parts of a scene defined in the flags table. Each scene can have a
-- unique modify function that handles received flags respectively.
--
-- The modify function is not intended to restart a scene, to do this
-- first purge then add the scene again.
function scene.modify(flags)
  for k, v in pairs(flags) do
    if k == "visible" then
      scene.visible = v
    end
    if k == "content" then
      scene.content = v
    end
    if k == "mode" then
      scene.mode = v
    end
  end
end

scene.modes = {
  {
    modifier = 'c',
    id = 'combat',
    mode = 'Combat Debug',
    description = '',
    content = '',
    callback = nil,
    visible = true,
    hasPanel = true
  },
  {
    modifier = 'g',
    id = 'grid',
    mode = 'Grid Debug',
    description = 'Shows the grid overlay for debugging sprite positions.',
    content = 'Velit qui aliqua culpa Lorem non velit tempor.',
    callback = function()
      scene.drawOverlay = true
      scene.overlay_image = {
        image = grid_overlay_image,
        x = 0,
        y = 0
      }
    end,
    visible = true,
    hasPanel = false
  },
  {
    modifier = 'm',
    id = 'mouse',
    mode = '',
    description = 'Mouse Position',
    content = '',
    callback = nil,
    visible = true,
    hasPanel = false
  },
}

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  scene.visible = false
  scene.content = ''
  scene.mode = ''

  local panelWidth = ViewportManager:getWidth() / 2
  panel = {
    x = ViewportManager:getWidth() + panelWidth, -- TO love.graphics.getWidth() - width
    y = 0,
    width = panelWidth,
    height = ViewportManager:getHeight(),
    padding = 25
  }
end

-- Scene updates loop
function scene.update(dt)
  if love.keyboard.isDown('f3') then
    for _, v in pairs(scene.modes) do
      if love.keyboard.isDown(v.modifier) then
        scene.visible = v.visible
        scene.mode = v.mode
        scene.activeModifers[v.modifier] = true
        scene.id = v.id
        if v.hasPanel then
          scene.content = v.content
          Tween.to(panel, 0.5, { x = ViewportManager:getWidth() - panel.width }):ease("quadout")
        end
        if v.callback then
          v.callback()
        end
      end
    end
  end

  if love.keyboard.isDown('escape') then
    -- love.mouse.setCursor(DefaultCursor)
    if not scene.hasPanel then
      scene.activeModifers = {}
      scene.drawOverlay = false
      scene.visible = false
      scene.content = ''
      scene.mode = ''
    else
      Tween.to(panel, 0.5, { x = ViewportManager:getWidth() + panel.width }):ease("quadout"):oncomplete(function()
        scene.activeModifers = {}
        scene.visible = false
        scene.content = ''
        scene.mode = ''
      end)
    end
  end

  if scene.activeModifers['c'] ~= nil and GameState.initiative then
    local actor = GameState.initiative.actor
    scene.content = string.format([[
CURRENT:
  ROUND: %s
  CURR PHASE: %s
  NEXT PHASE: %s

ACTOR: %s
  ID: %d
  HP: %d
  INIT: %d
  DEF: %d
  XP: %d
  GOLD: %d
  GEM: %d
  TOKEN: %d
]],
      GameState.initiative.round,
      actor.phaseState.id,
      actor.phaseState.next,
      actor.name,
      actor.uid,
      actor.stats.health or 0,
      actor.stats.rolledInitiative or 0,
      actor.stats.defense or 0,
      actor.stats.xpAmount or 0,
      actor.stats.gold or 0,
      actor.stats.gems or 0,
      actor.stats.spinTokens or 0
    )
  end

  if scene.activeModifers['m'] or scene.activeModifers['g'] then
    -- love.mouse.setCursor(debugCursor)
  end
end

-- Scene draw loop
function scene.draw()
  if scene.visible then
    love.graphics.setColor(1, 1, 1, 0.80)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    if scene.drawOverlay then
      love.graphics.draw(scene.overlay_image.image, scene.overlay_image.x, scene.overlay_image.y)
    end

    if scene.content then
      love.graphics.setColor(0, 0, 0, 1)
      FontsManager:setFontBMP('sm', 'Medium')
      love.graphics.printf("DEBUG MODE " .. scene.mode .. "\n\n" .. scene.content, panel.x + panel.padding,
        panel.padding,
        panel.width - panel.padding * 2, "left")
    end

    if scene.activeModifers['m'] then
      -- viewport and mouse measurements
      local mx, my = ViewportManager:getMousePosition()
      local w, h = ViewportManager:getDimensions()

      -- Set the width and height for the mouse coordinate display box
      local d_w, d_h = 48, 15
      local d_w_center, d_y_center = math.floor(d_w / 2), math.floor(d_h / 2)
      local d_letter_ox, d_letter_oy = 0, 4
      local half_cursor = GameState.cursor:getWidth() / 2

      -- default positions for the display,
      local adjusted_mx = mx - d_w_center
      local adjusted_my = my - d_y_center + half_cursor

      local d_y_bottom = my + d_h / 2 + half_cursor

      local distance_from_edge = 8

      -- If the box would go off the right edge, shift it left
      if mx + distance_from_edge + d_w_center >= w then
        adjusted_mx = w - d_w - distance_from_edge
      end

      -- If the box would go off the left edge, shift it right
      if mx - distance_from_edge - d_w_center <= 0 then
        adjusted_mx = distance_from_edge
      end

      -- If the box would go off the bottom edge, shift it up
      if d_y_bottom >= h - distance_from_edge then
        adjusted_my = my - d_h - half_cursor / 2
      end

      -- If the mouse is below the viewport, clamp the box to the bottom
      if my > h then
        adjusted_my = h - distance_from_edge - d_h -- THis pins to the bottom.
      end

      -- If the mouse is above the viewport, clamp the box to the top
      if my < 0 then
        adjusted_my = distance_from_edge
      end

      adjusted_mx = math.floor(adjusted_mx)
      adjusted_my = math.floor(adjusted_my)

      love.graphics.setColor(1, 1, 1, 0.80)
      love.graphics.rectangle("fill", adjusted_mx, adjusted_my, d_w, d_h, 3, 3)
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("line", adjusted_mx, adjusted_my, d_w, d_h, 3, 3)
      love.graphics.printf(string.format("%d, %d", mx, my), adjusted_mx, adjusted_my + d_letter_oy, d_w, "center")
    end
  end
end

return scene
