local cur = SceneManager.current
local scene = {}
scene.zsort = 100000
scene.drawOverlay = false
scene.overlay_image = nil
scene.activeModifers = {}

local grid_overlay_image = love.graphics.newImage("assets/images/grid_overlay.png")


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
    modifier = 'a',
    id = 'refresh_all',
    mode = 'Some future Debug panel',
    description = 'Refresh the current scene',
    content =
    'In sunt officia ex.\n\nSint Lorem qui minim elit laborum ipsum voluptate veniam id. Aliquip id ex labore magna veniam velit mollit exercitation aute cupidatat fugiat magna. Tempor non mollit esse voluptate quis pariatur. Elit consequat amet aliqua irure magna consequat ex ut cillum cupidatat non. Voluptate eiusmod nostrud velit consequat.\n\nCommodo ipsum amet ad amet ut nulla ad sint id eiusmod Lorem irure mollit. Deserunt ipsum esse qui laborum dolor Lorem sunt Lorem magna tempor veniam consequat proident est laborum. Ex eu in consectetur cillum exercitation Lorem veniam minim. Dolor id ex deserunt tempor duis in fugiat. Aliqua sint ut id anim veniam culpa do deserunt aliquip do anim nulla. Duis veniam magna eu elit quis aliquip. Ea tempor sit exercitation id nulla ad laborum consectetur do in. Anim officia aliquip amet excepteur voluptate mollit enim eu occaecat magna eiusmod veniam.',
    visible = true,
    callback = nil,
    hasPanel = true
  },
  {
    modifier = 'b',
    id = 'something_else',
    mode = 'A different debug panel',
    description = 'Does something else?',
    content = 'Velit qui aliqua culpa Lorem non velit tempor.',
    callback = nil,
    visible = true,
    hasPanel = true
  },
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
    mode = 'Mouse Position',
    description = '',
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
  TURN: %s - %d
  PHASE: %s
    NextPhase: %s

ACTOR:
  HP: %d
  INIT: %d
  DEF: %d
]],
      GameState.initiative.round,
      actor.name,
      actor.uid,
      actor.phaseState.id,
      actor.phaseState.next,
      actor.stats.health,
      actor.stats.rolledInitiative,
      actor.stats.defense
    )
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

    if scene.activeModifers['m'] ~= nil then
      local mx, my = ViewportManager:getMousePosition()
      local w, h = ViewportManager:getDimensions()
      -- Set the width and height for the mouse coordinate display box
      local m_width, m_height = 48, 15

      local adjusted_mx = mx
      local adjusted_my = my

      -- If the box would go off the right edge, shift it left
      if mx + m_width >= w then
        adjusted_mx = mx - m_width
      end

      -- If the box would go off the bottom edge, shift it up
      if my + m_height * 2 >= h then
        adjusted_my = my - m_height * 3
      end

      -- If the mouse is below the viewport, clamp the box to the bottom
      if my > h then
        adjusted_my = h - m_height * 3
      end

      -- If the mouse is above the viewport, clamp the box to the top
      if my < 0 then
        adjusted_my = 0
      end

      love.graphics.setColor(1, 1, 1, 0.80)
      love.graphics.rectangle("fill", adjusted_mx, adjusted_my + m_height, m_width, m_height, 3, 3)
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("line", adjusted_mx, adjusted_my + m_height, m_width, m_height, 3, 3)
      love.graphics.printf(string.format("%d, %d", mx, my), adjusted_mx, adjusted_my + m_height + 4, m_width, "center")
    end
  end
end

return scene
