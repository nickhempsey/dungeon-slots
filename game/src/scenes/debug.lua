local cur = SceneManager.current
local scene = {}
scene.zsort = 100000
scene.drawOverlay = false
scene.overlay_image = nil

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
  }
}

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  scene.visible = false
  scene.content = ''
  scene.mode = ''

  local panelWidth = love.graphics.getWidth() / 2
  panel = {
    x = love.graphics.getWidth() + panelWidth, -- TO love.graphics.getWidth() - width
    y = 0,
    width = panelWidth,
    height = love.graphics.getHeight(),
    padding = 25
  }
end

-- Scene updates loop
function scene.update(dt)
  if love.keyboard.isDown('f3') then
    for _, v in pairs(scene.modes) do
      if love.keyboard.isDown(v.modifier) then
        LogManager.info("Debug Mode: " .. v.mode .. "\n\n" .. v.description)
        scene.visible = v.visible
        scene.mode = v.mode
        if v.hasPanel then
          scene.content = v.content
          Tween.to(panel, 0.5, { x = love.graphics.getWidth() - panel.width }):ease("quadout")
        end
        if v.callback then
          v.callback()
        end
      end
    end
  end

  if love.keyboard.isDown('escape') then
    Tween.to(panel, 0.5, { x = love.graphics.getWidth() + panel.width }):ease("quadout"):oncomplete(function()
      scene.visible = false
      scene.content = ''
      scene.mode = ''
    end)
  end
end

-- Scene draw loop
function scene.draw()
  if scene.visible then
    love.graphics.setColor(1, 1, 1, 0.70)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    if scene.drawOverlay then
      love.graphics.draw(scene.overlay_image.image, scene.overlay_image.x, scene.overlay_image.y)
    end

    -- love.graphics.setFont(Fonts.md)
    -- love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf("Debug Mode: " .. scene.mode .. "\n\n" .. scene.content, panel.x + panel.padding, panel.padding,
      panel.width - panel.padding * 2, "left")
  end
end

return scene
