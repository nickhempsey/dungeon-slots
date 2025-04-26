local scene = {}
scene.visible = false
local cur = SceneManager.current

local toggleButton1 = Button:new("Debug", 10, 250, function()
  scene.visible = not scene.visible
end)
toggleButton1:size('sm')
local toggleButton2 = Button:new("Debug", 150, 250, function()
  scene.visible = not scene.visible
end)
toggleButton2:size('md')
local toggleButton3 = Button:new("Debug", 300, 250, function()
  scene.visible = not scene.visible
end)
toggleButton3:size('lg')

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
  end
end

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
  -- scene.visible = false
end

-- Scene updates loop
function scene.update(dt)
  toggleButton1:update(dt)
  toggleButton2:update(dt)
  toggleButton3:update(dt)
  if love.keyboard.isPressed("f3") then
    scene.visible = not scene.visible
  end
end

-- Scene draw loop
function scene.draw()
  toggleButton1:draw()
  toggleButton2:draw()
  toggleButton3:draw()
  if scene.visible then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Debug Mode Active", 600, 600)
  end
end

return scene
