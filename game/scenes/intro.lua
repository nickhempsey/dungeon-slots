local hexToRGBA = require "utils.hexToRGBA"
local cur = SceneManager.current
local scene = {}
scene.zsort = 100

local background = love.graphics.newImage("assets/images/UI_Layout.png")

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
  local midX, midY = ViewportManager:getMidScreen()
  local handleClick = function(self)
    self.onBlur(self)
    SceneManager.add('combat')
    SceneManager.purge('intro')
  end
  local handleHover = function(self)
    if not self.tooltip then
      self.tooltip = Tooltip:new(I18n.t("ui.main.start_tooltip"), 'center', 120, 18)
    end
  end
  local handleBlur = function(self)
    if self.tooltip then
      TooltipManager.unregister(self.tooltip.uid)
      self.tooltip = nil
    end
  end
  StartButton = Button:new(I18n.t("ui.main.start_label"), midX, midY, handleClick, handleHover, handleBlur)
  StartButton:size('md')
  StartButton:set('x', midX - StartButton.width / 2)
  StartButton:set('y', midY - StartButton.height / 2)
  StartButton:set('font', 'Pixellari')
end

-- Scene updates loop
function scene.update(dt)
  StartButton:update(dt)
end

-- Scene draw loop
function scene.draw()
  love.graphics.setColor(hexToRGBA('#cdcdcd'))
  love.graphics.draw(background, 0, 0)

  StartButton:draw()
end

return scene
