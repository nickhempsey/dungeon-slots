-- debugging and logging
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
if love.filesystem then io.stdout:setvbuf("no") end

InputManager = require "lib.InputManager"
SceneManager = require "lib.SceneManager".newManager()
EventBus = require "lib.EventBus"
Button = require "src.components.Button"
Colors = require "config.Colors"
Fonts = require "config.Fonts"

-- You can also seperate out the function call as shown in the comments below.
-- local SceneManager = require "lib.StackingSceneMgr"
-- local SceneManager = SceneManager.newManager()

function love.load()
  SceneManager.setPath("scenes/")
  SceneManager.add("debug")
  SceneManager.add("intro")


  SceneManager.modify("debug", { visible = false })
end

function love.update(dt)
  SceneManager.update(dt)

  love.keyboard.resetInputStates()
end

function love.draw()
  SceneManager.draw()
end
