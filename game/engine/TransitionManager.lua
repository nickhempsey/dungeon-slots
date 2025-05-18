--------------------
-- ERROR CHECKERS --
--------------------
local funcDefined = require "utils.funcDefined"
local pathDefined = require "utils.pathDefined"

local module = {}

function module.newManager()
  -- Transition properties
  local transition    = {}

  transition.dir      = nil -- The directory for your transitions
  transition.name     = nil -- Identity in error checkers
  transition.effect   = nil -- The transition effect
  transition.response = nil -- The result post transition effect
  transition.params   = nil -- The results params


  --                          --
  ------------------------------
  -- TRANSITION MANAGER CALLS --
  ------------------------------
  --                          --
  function transition.setPath(path)
    assert(type(path) == "string", "Function 'setPath': parameter must be a string.")

    -- Add trailing "/" if none is found (47 = /)
    if string.byte(path, #path) ~= 47 then
      path = path .. "/"
    end

    if pathDefined(path) then
      transition.dir = path
    end
  end

  --                      --
  -- Transition specifics --
  --                      --

  function transition.unload(fileName)
    assert(type(fileName) == "string", "Function 'unload': parameter must be a string.")

    local path          = transition.dir .. fileName

    transition.name     = nil
    transition.effect   = nil
    transition.response = nil
    transition.params   = nil

    -- Remove required transition
    if pathDefined(path .. ".lua") then
      if package.loaded[transition.dir .. effect] then
        package.loaded[transition.dir .. effect] = nil
      end
    end
  end

  function transition.load(fileName, response, params)
    assert(type(fileName) == "string", "Function 'load': First parameter must be a string.")
    assert(type(response) == "function", "Function 'load': Second parameter must be a function.")

    local path = transition.dir .. fileName

    transition.name = fileName

    if pathDefined(path .. ".lua") then
      transition.effect = require(path)
      transition.response = response
      transition.params = params

      if funcDefined("load", transition) then
        transition.effect.load()
      end
    end
  end

  function transition.result(params)
    if type(params) == 'table' then
      transition.response(unpack(params))
    else
      transition.response(params)
    end
  end

  --                      --
  -- Game transition Loop --
  --                      --

  function transition.update(dt)
    assert(type(dt) == "number", "Function 'update': parameter must be a number.")

    if funcDefined("update", transition) then
      -- Update the transition
      transition.effect.update(dt)
    end
  end

  function transition.draw()
    if funcDefined("draw", transition) then
      -- Draw the transition
      transition.effect.draw()
    end
  end

  return transition
end
