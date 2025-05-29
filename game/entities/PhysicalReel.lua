local deepcopy = require "utils.deepcopy"
local uuid = require "utils.uuid"

--[[
--]]

local PhysicalReel = {}
PhysicalReel.__index = PhysicalReel

PhysicalReel.debug = Debug
PhysicalReel.debugLabel = LogManagerColor.colorf('{green}[Reel]{reset}')

--[[
--]]
function PhysicalReel:new(symbols)
  assert(type(symbols) == "table", "symbols must be a table")
  local instance = setmetatable({
    symbols  = symbols,
    expanded = {}, -- Takes the symbol.qty and creates "physical" copies of them.
    current  = {}, -- The most recent or current roll.
    previous = {}, -- Historic rolls.
    slots    = {}, -- The Randomized slots, the length based on the slotQty
    slotsQty = 3,  -- The number of slots to generate
  }, self)

  instance:expand()
  instance:buildSlots()

  LogManager.info(string.format("%s new reel generated", PhysicalReel.debugLabel))
  LogManager.info(instance)

  return instance
end

function PhysicalReel:expand()
  if self.symbols then
    for _, symbol in pairs(self.symbols) do
      for i = 1, symbol.qty do
        local copy = {
          id = symbol.id
        }
        table.insert(self.expanded, copy)
      end
    end
  end
end

function PhysicalReel.shuffle(r)
  local copy = deepcopy(r)
  for i = #copy, 2, -1 do
    local j = love.math.random(i) -- random integer between 1 and i
    copy[i], copy[j] = copy[j], copy[i]
    copy[i].idx = i
    copy[j].idx = j
  end

  return copy
end

function PhysicalReel:buildSlots()
  for i = 1, self.slotsQty do
    local shuffledSlot = self.shuffle(self.expanded)
    table.insert(self.slots, shuffledSlot)
  end
end

function PhysicalReel:spinReel()
  LogManager.info("-------- START REEL--------")
  if self.current then
    table.insert(self.previous, self.current)
  end

  self.current = {
    id = uuid(),
    timestamp = os.time(),
    slots = deepcopy(self.slots),
    selected = {},
  }
  for i = 1, self.slotsQty do
    local rng = love.math.random(1, #self.expanded)
    local selectedSymbol = self.slots[i][rng]
    table.insert(self.current.selected, selectedSymbol)
  end

  EventBusManager:publish('reel_spun_end', self.current)

  LogManager.info("-------- START RESULTS--------")
  LogManager.info(self.current.selected)
  LogManager.info("-------- END RESULTS--------")
end

function PhysicalReel:getSymbolById(id)
  if not self.symbols then return end

  for _, symbol in pairs(self.symbols) do
    if symbol.id == id then
      return symbol
    end
  end

  return nil
end

function PhysicalReel:getCurrent()
  return self.current
end

function PhysicalReel:getPrevious()
  return self.previous
end

function PhysicalReel:drawSlot(reference, slot, selected, origin_x, origin_y, buffer_x, buffer_y)
  local x = origin_x or 0
  local y = origin_y or 0 -- increments every frame.
  buffer_x = buffer_x or 0
  buffer_y = buffer_y or 0

  local relative_y_offset = (32 + buffer_y)

  love.graphics.setColor(0, 0, 0)

  -- preprend the last symbol to the front
  local lastDupe = reference:getSymbolById(slot[#slot].id)
  local lastImage = lastDupe.assets.images.reel.image
  love.graphics.draw(lastImage, x, y - relative_y_offset)

  for i, symbol in ipairs(slot) do
    local symbolReference = reference:getSymbolById(symbol.id)
    if symbolReference then
      local image = symbolReference.assets.images.reel.image
      if i > 1 then
        y = y + relative_y_offset
      end

      if selected.idx == i then
        love.graphics.setColor(1, 1, 1, 1)
      end
      love.graphics.draw(image, x, y)
      love.graphics.setColor(0, 0, 0, .4)
    end
  end

  -- append the first symbol to the end
  local firstDupe = reference:getSymbolById(slot[1].id)
  local firstTmage = firstDupe.assets.images.reel.image
  love.graphics.draw(firstTmage, x, y + relative_y_offset)
end

function PhysicalReel:drawReel(reference, reel, origin_x, origin_y, buffer_x, buffer_y)
  if not reel.slots then return end

  local x = origin_x or 0
  local y = origin_y or 0
  buffer_x = buffer_x or 0
  buffer_y = buffer_y or 0

  for i, slot in ipairs(reel.slots) do
    -- All images in the reel are 32 x 32.
    local selectedSlotSymbol = reel.selected[i]
    local y_buffer_offset = (((selectedSlotSymbol.idx or 1) - 1) * buffer_y)
    local incremental_offset = ((selectedSlotSymbol.idx or 1) * 32)
    y = y - (incremental_offset + y_buffer_offset) + 64

    if i > 1 then
      x = x + buffer_x + 32
    end
    self:drawSlot(reference, slot, selectedSlotSymbol, x, y, buffer_x, buffer_y)
    y = origin_y
  end
end

return PhysicalReel
