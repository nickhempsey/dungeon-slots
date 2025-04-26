local scene = {}

local font = love.graphics.newFont(20)
local x = 34
local y = love.graphics.getHeight() - 42

local self = SceneManager.current
local color = {}
color.r = 255
color.g = 255
color.b = 0
local toggle = Button:new("Toggle", 20, 250, function()
  scene.purge(self)
end)

toggle.set('bg', Colors.background)
toggle.set('hoverBg', Colors.accent)


-- This is just for getting colors to work across love versions
-- In love 11 colors are values of 0-1, unlike earlier versions.
local major, minor, revision, _ = love.getVersion()

-- In this modify function we take the flags then go through by key value
-- if our k is "x" then we set it to v
-- if our k is "y" then we set it to v
-- This is a flexable system for modifying data about your scene on the fly
function scene.modify(flags)
  for k, v in pairs(flags) do
    if k == "x" then
      x = v
    elseif k == "y" then
      y = v
    end
  end
end

function scene.load()
end

function scene.update(dt)
  toggle:update(dt)
end

function scene.draw()
  toggle:draw()

  love.graphics.setColor(1, 1, 1, 1)
  -- Info text
  love.graphics.setFont(font)
  love.graphics.print('inventory', 40, 330)

  love.graphics.setColor(color.r, color.g, color.b, 255)
  love.graphics.rectangle("fill", x, y, 32, 32)
end

return scene
