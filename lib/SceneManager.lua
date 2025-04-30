--------------------
-- ERROR CHECKERS --
--------------------
local funcDefined = require "utils.funcDefined"
local pathDefined = require "utils.pathDefined"

local module = {}

function module.newManager()
  -- Scene and properties
  local scene      = {}
  scene.dir        = nil  -- The directory for your scenes (string)

  scene.current    = nil  -- current scene file name (string) (top scene)
  scene.previous   = nil  -- previous scene file name (string) (scene before top scene)

  scene.table      = {}   -- A table of all the target files in a key value pair
  scene.drawOrder  = {}   -- A table specifically for draw order to help with z-fighting
  scene.zsortDirty = true -- Enables caching of the drawOrder table

  scene.debug      = Debug
  scene.debugLabel = LogManagerColor.colorf('{yellow}[SceneManager]{reset} ')

  -------------------------
  -- SCENE MANAGER CALLS --
  -------------------------

  -- Used to set the path to your scenes folder
  function scene.setPath(path)
    assert(type(path) == "string", "Function 'setPath': parameter must be a string.")

    -- Add trailing "/" if none is found (47 = /)
    if string.byte(path, #path) ~= 47 then
      path = path .. "/"
    end


    if pathDefined(path) then
      scene.dir = path
    end
  end

  -- Allows changing scene variables (flags) passed as a table
  function scene.modify(fileName, flags)
    assert(type(fileName) == "string", "Function 'modify': first parameter must be a string.")
    assert(type(flags) == "table" or type(flags) == "nil", "Function 'modify': second parameter must be a table or nil.")

    -- You can modify parts of a scene by passing flags, i.e. a table of variables to be modified.
    -- The modify functionality is handled in the scenes modify function to give the developer max control.
    if funcDefined("modify", scene) then
      scene.table[fileName].modify(flags) -- Run scenes modify function
      if scene.debug then
        LogManager.debug(string.format('%s modifying flags of scene: %s', scene.debugLabel, fileName))
        LogManager.debug(flags)
      end
    end
  end

  ---------------------------
  -- Add and Remove Scenes --
  ---------------------------

  -- Add a scene to the scene table
  function scene.add(fileName)
    assert(type(fileName) == "string", "Function 'add': parameter must be a string.")

    local path       = scene.dir .. fileName

    scene.previous   = scene.current
    scene.current    = fileName
    scene.zsortDirty = true

    if pathDefined(path .. ".lua") then
      scene.table[scene.current] = require(path) -- key value

      if funcDefined("load", scene) then
        scene.table[scene.current].load() -- run scenes load funciton
        if scene.debug then
          LogManager.debug('%s Loaded scene: %s', scene.debugLabel, fileName)
        end
      end
    end
  end

  -- Remove a scene from the scene table
  function scene.remove(fileName)
    assert(type(fileName) == "string", "Function 'remove': parameter must be a string.")

    local path = scene.dir .. fileName
    scene.zsortDirty = true

    if pathDefined(path .. ".lua") then
      if package.loaded[path] then
        scene.table[fileName] = nil
        if scene.debug then
          LogManager.debug('%s Removed scene: %s', scene.debugLabel, fileName)
        end
      end
    end
  end

  -- Remove a scene from the scene table and unload it's data
  function scene.purge(fileName)
    assert(type(fileName) == "string", "Function 'remove': parameter must be a string.")

    local path = scene.dir .. fileName
    scene.zsortDirty = true

    if pathDefined(path .. ".lua") then
      if package.loaded[path] then
        package.loaded[path] = nil
        scene.table[fileName] = nil

        if scene.debug then
          LogManager.debug('%s Purge scene: %s', scene.debugLabel, fileName)
        end
      end
    end
  end

  -- Removes all scenes from scene table
  function scene.removeAll()
    scene.previous   = nil
    scene.current    = nil
    scene.table      = {}
    scene.zsortDirty = true

    if scene.debug then
      LogManager.debug('%s Remove all scenes', scene.debugLabel)
    end
  end

  -- Removes all scenes from scene table and unloads their data
  function scene.purgeAll()
    for k, v in pairs(scene.table) do
      local path = scene.dir .. k

      if package.loaded[path] then
        package.loaded[path] = nil
      end
    end

    scene.previous   = nil
    scene.current    = nil
    scene.table      = {}
    scene.zsortDirty = true

    if scene.debug then
      LogManager.debug('%s Purge all scenes')
    end
  end

  ---------------------------------
  -- Freeze and Unfreeze a Scene --
  ---------------------------------

  -- Returns if scene is frozen or not (boolean)
  function scene.isFrozen(fileName)
    assert(type(fileName) == "string", "Function 'isFrozen': first parameter must be a string.")

    return scene.table[fileName].frozen
  end

  -- Toggles if scene is frozen or not
  function scene.setFrozen(fileName, toggle)
    assert(type(fileName) == "string", "Function 'setFrozen': first parameter must be a string.")
    assert(type(toggle) == "boolean", "Function 'setFrozen': second parameter must be a boolean.")

    if scene.debug then
      LogManager.debug('%s Scene frozen: %s', scene.debugLabel, fileName)
    end

    scene.table[fileName].frozen = toggle
  end

  -----------------------
  -- Game (scene) Loop --
  -----------------------

  -- Updates current scenes
  function scene.update(dt)
    assert(type(dt) == "number", "Function 'update': parameter must be a number.")

    if funcDefined("update", scene) then
      for k, v in pairs(scene.table) do
        scene.table[k].update(dt)
      end
    end
  end

  -- Only sort if something changed
  function scene.draw()
    if scene.zsortDirty then
      if scene.debug then
        LogManager.debug('%s Sorting scenes', scene.debugLabel)
      end

      scene.drawOrder = {}
      for _, v in pairs(scene.table) do
        table.insert(scene.drawOrder, v)
      end

      table.sort(scene.drawOrder, function(a, b)
        return (a.zsort or 0) < (b.zsort or 0)
      end)

      scene.zsortDirty = false -- Sorted, no longer dirty
    end

    -- Draw in sorted order
    for _, sceneObj in ipairs(scene.drawOrder) do
      sceneObj.draw()
    end
  end

  return scene
end

return module
