local scene = {}
scene.visible = false
local cur = SceneManager.current

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
      EventBusManager:publish("debug_visible", v)
    end
  end
end

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  button = Button:new("Debug", 0, 250, function()
    scene.modify({ visible = not scene.visible })
  end)
  button:set('x', love.graphics.getWidth() - button.width * 2)
  button:set('y', love.graphics.getHeight() - button.height * 2)
  button:size('md')
  button:set('keybind', 'f3')
end

-- Scene updates loop
function scene.update(dt)
  button:update(dt)

  if scene.visible then
    button.label = 'Close'
  else
    button.label = 'Debug'
  end
end

-- Scene draw loop
function scene.draw()
  button:draw()

  if scene.visible then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Debug Mode Active", 600, 600)
  end
end

return scene
