SSM = require "lib.StackingSceneMgr".newManager()
Button = require "src.components.Button"
Colors = require "config.Colors"
Fonts = require "config.Fonts"

-- You can also seperate out the function call as shown in the comments below.
-- local SSM = require "lib.StackingSceneMgr"
-- local SSM = SSM.newManager()

function love.load()
  -- Set path of your scene files
  SSM.setPath("scenes/")

  -- Add scene "intro" to scene table
  SSM.add("intro")
end

function love.update(dt)
  -- Update the scene table
  SSM.update(dt)
end

function love.draw()
  -- Render the scene table
  SSM.draw()
end
