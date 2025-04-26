local EventBus = {}

EventBus.listeners = {}
EventBus.debug = false

-- Subscribe to an event
function EventBus:subscribe(event, callback, owner, priority)
  if not self.listeners[event] then
    self.listeners[event] = {}
  end
  table.insert(self.listeners[event], {
    callback = callback,
    owner = owner,
    priority = priority or 0
  })

  -- Sort by priority: higher priority first
  table.sort(self.listeners[event], function(a, b)
    return a.priority > b.priority
  end)

  if self.debug then
    print(string.format("[EventBus] Subscribed to '%s' (priority: %d)", event, priority or 0))
  end
end

-- Subscribe to an event, but only once
function EventBus:once(event, callback, owner, priority)
  local function wrapper(...)
    self:unsubscribe(event, wrapper)
    callback(...)
  end
  self:subscribe(event, wrapper, owner, priority)
end

-- Unsubscribe a specific callback from an event
function EventBus:unsubscribe(event, callback)
  if not self.listeners[event] then return end
  for i = #self.listeners[event], 1, -1 do
    if self.listeners[event][i].callback == callback then
      table.remove(self.listeners[event], i)

      if self.debug then
        print(string.format("[EventBus] Unsubscribed from '%s'", event))
      end
    end
  end
end

-- Clear all listeners tied to an owner
function EventBus:clearByOwner(owner)
  for event, listeners in pairs(self.listeners) do
    for i = #listeners, 1, -1 do
      if listeners[i].owner == owner then
        table.remove(listeners, i)
      end
    end
  end
end

-- Publish an event, calling all listeners
function EventBus:publish(event, ...)
  if self.debug then
    local args = { ... }
    local argsStr = ""
    for i, v in ipairs(args) do
      argsStr = argsStr .. tostring(v) .. (i < #args and ", " or "")
    end
    print(string.format("[EventBus] Publishing event '%s' with args: %s", event, argsStr))
  end

  if not self.listeners[event] then return end

  -- Copy the list first to avoid issues if listeners unsubscribe during iteration
  local listenersCopy = {}
  for i, listener in ipairs(self.listeners[event]) do
    listenersCopy[i] = listener
  end
  for _, listener in ipairs(listenersCopy) do
    listener.callback(...)
  end
end

-- Helper: Check if there are any listeners for an event
function EventBus:hasListeners(event)
  return self.listeners[event] and #self.listeners[event] > 0
end

return EventBus
