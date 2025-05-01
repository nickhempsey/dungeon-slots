local funcDefined = function(func, scene)
  -- Make sure our scene exists
  if scene.current == nil then
    if #scene.table == 0 then
      error("Scene table is empty, no scenes found.")
    else
      error("Current scene is nil.")
    end
  end

  -- Make sure function is defined
  if scene.table[scene.current][func] then
    if type(scene.table[scene.current][func]) == 'function' then
      return true
    else
      error("\'" .. scene.dir .. scene.current .. ".lua\': " .. func .. " should be a function.")
    end
  else
    error("\'" .. scene.dir .. scene.current .. ".lua\': " .. func .. " function is not defined.")
  end
end

return funcDefined
