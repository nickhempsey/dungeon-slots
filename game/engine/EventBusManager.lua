local unpack = require "utils.unpack"

local EventBusManager = {}

EventBusManager.listeners = {}

EventBusManager.debug = Debug
EventBusManager.debugLabel = LogManagerColor.colorf('{red}[EventBusManager]{reset}')

--- Subscribe to an event
---
---@param event string
---@param callback function
---@param owner table
---@param priority number
---@param context table
function EventBusManager:subscribe(event, callback, owner, priority, context)
  assert(type(event) == "string", "Function 'subscribe': first parameter must be a string.")
  assert(type(callback) == "function", "Function 'subscribe': second parameter must be a function.")

  if not self.listeners[event] then
    self.listeners[event] = {}
  end

  table.insert(self.listeners[event], {
    callback = callback,
    context  = context,
    owner    = owner,
    priority = priority or 0
  })

  -- Sort by priority: higher priority first
  table.sort(self.listeners[event], function(a, b)
    return a.priority > b.priority
  end)

  if self.debug then
    LogManager.debug(string.format("%s '%s' subscribed to: '%s' (priority: %d)", EventBusManager.debugLabel, owner, event,
      priority or 0))
  end
end

--- Subscribe to an event, but only once
---
---@param event string
---@param callback function
---@param owner table
---@param priority number
---@param context table
function EventBusManager:once(event, callback, owner, priority, context)
  assert(type(event) == "string", "Function 'once': first parameter must be a string.")
  assert(type(callback) == "function", "Function 'once': second parameter must be a function.")

  -- Wrap the callback
  local function wrapper(...)
    self:unsubscribe(event, wrapper)
    callback(...)
  end
  self:subscribe(event, wrapper, owner, priority, context)
end

--- Unsubscribe a specific callback from an event
---
---@param event string
---@param callback function
function EventBusManager:unsubscribe(event, callback)
  assert(type(event) == "string", "Function 'unsubscribe': first parameter must be a string.")

  if not self.listeners[event] then return end
  for i = #self.listeners[event], 1, -1 do
    if self.listeners[event][i].callback == callback then
      table.remove(self.listeners[event], i)

      if self.debug then
        LogManager.debug(string.format("%s Unsubscribed from: '%s'", EventBusManager.debugLabel, event))
      end
    end
  end
end

--- Clear all listeners tied to an owner
---
---@param owner string
function EventBusManager:clearByOwner(owner)
  assert(type(owner) == "string", "Function 'clearByOwner': parameter must be a string.")

  for _, listeners in pairs(self.listeners) do
    for i = #listeners, 1, -1 do
      if listeners[i].owner == owner then
        table.remove(listeners, i)
      end
    end
  end
end

--- Publish an event, calling all listeners
---
---@param event string
---@param ... any
function EventBusManager:publish(event, ...)
  assert(type(event) == "string", "Function 'publish': first parameter must be a string.")

  if self.debug then
    LogManager.debug(string.format("%s Publishing event '%s'", EventBusManager.debugLabel, event))
    if ... ~= nil then
      LogManager.debug(...)
    end
  end

  if not self:hasListeners(event) then return end

  local ls = self.listeners[event]
  local copy = { unpack(ls) }

  for _, listener in ipairs(copy) do
    if listener.context then
      listener.callback(listener.context, ...)
    else
      listener.callback(...)
    end
  end
end

--- Helper: Check if there are any listeners for an event
---
---@param event string
function EventBusManager:hasListeners(event)
  assert(type(event) == "string", "Function 'hasListeners': parameter must be a string.")

  return self.listeners[event] and #self.listeners[event] > 0
end

return EventBusManager
