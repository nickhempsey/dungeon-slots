local scene = {}

local x = 10
local font = love.graphics.newFont(20)
local cur = SSM.current

-- Stacking Scene Manager can be used to call a scenes modify function.
-- The modify function is intended to be used for changing specific
-- parts of a scene defined in the flags table. Each scene can have a
-- unique modify function that handles received flags respectively.
--
-- The modify function is not intended to restart a scene, to do this
-- first purge then add the scene again.
function scene.modify(flags)
end

-- Stacking Scene Manager can all a scenes load function. The purpose of
-- this function is to initialize variables. Though they can also be
-- initialized outside of the load function for persistent state.
function scene.load()
end

-- Scene updates loop
function scene.update()
  function love.keypressed(key, unicode)
  end
end

-- Scene draw loop
function scene.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font)
  love.graphics.print(
    'Base Scene',
    20,
    20
  )

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle("fill", x, 200, 150, 100)
end

return scene
