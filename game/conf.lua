local isDevelopment = require "utils.isDevelopment"

function love.conf(t)
  -- Game Info
  t.window.title = "Dungeon Slots"
  t.version = "11.4"

  -- Window Specs
  t.window.width = 1920
  t.window.height = 1080
  -- t.window.width = 640
  -- t.window.height = 360
  t.window.resizable = false
  t.window.fullscreen = true

  -- Dev only adjusments
  if isDevelopment then
    --t.window.x = 200
    --t.window.y = 200
    t.window.display = 2
    t.console = false
  end
end
