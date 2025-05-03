local anim8 = require "utils.anim8"
local unpack = require "utils.unpack"

local AnimationManager = {}

---@param animationData table -- Parsed Aseprite JSON
---@return nil | table -- <anim8.Animation>
function AnimationManager.buildFromAseprite(animationData)
  if type(animationData) ~= 'table' then
    return nil
  end

  local animations = {}
  local frames = AnimationManager.getSortedFrames(animationData.frames)
  local frameWidth = frames[1].data.sourceSize.w
  local frameHeight = frames[1].data.sourceSize.h
  local imageW = animationData.meta.size.w
  local imageH = animationData.meta.size.h

  local grid = anim8.newGrid(frameWidth, frameHeight, imageW, imageH)

  for _, tag in ipairs(animationData.meta.frameTags or {}) do
    local name = tag.name
    local from = tag.from
    local to = tag.to
    local direction = tag.direction

    -- Build the sequence of frame indices for anim8 (1-based column positions)
    local range = {}
    if direction == "reverse" then
      for i = to, from, -1 do table.insert(range, i + 1) end
    elseif direction == "pingpong" then
      for i = from, to do table.insert(range, i + 1) end
      for i = to - 1, from + 1, -1 do table.insert(range, i + 1) end
    else -- "forward"
      for i = from, to do table.insert(range, i + 1) end
    end

    -- Build duration list per frame
    local durations = {}
    if direction == "reverse" then
      for i = to, from, -1 do
        local frame = frames[i + 1]
        table.insert(durations, frame.data.duration / 1000)
      end
    elseif direction == "pingpong" then
      for i = from, to do
        local frame = frames[i + 1]
        table.insert(durations, frame.data.duration / 1000)
      end
      for i = to - 1, from + 1, -1 do
        local frame = frames[i + 1]
        table.insert(durations, frame.data.duration / 1000)
      end
    else -- "forward"
      for i = from, to do
        local frame = frames[i + 1]
        table.insert(durations, frame.data.duration / 1000)
      end
    end

    -- All frames are on the first row, so we pass row = 1
    local anim = anim8.newAnimation(grid(unpack(range), 1), durations)
    animations[name] = anim
  end

  return animations
end

function AnimationManager.getSortedFrames(frames)
  local sorted = {}
  for name, frame in pairs(frames) do
    local index = tonumber(name:match("(%d+)")) or 0
    table.insert(sorted, { index = index, data = frame })
  end
  table.sort(sorted, function(a, b) return a.index < b.index end)
  return sorted
end

return AnimationManager
