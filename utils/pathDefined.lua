local pathDefined = function(path)
  local major, minor, revision, _ = love.getVersion()

  if major == 0 and minor == 9 and revision >= 1 then
    -- File system calls for love 0.9.1 and up to 0.11.0
    if love.filesystem.exists(path) then
      return true
    else
      error("Can't " .. debug.getinfo(2).name .. " \'" .. path .. "\': No such file or directory.")
    end
  elseif major == 11 and minor >= 0 and revision >= 0 then
    -- File system calls for love 0.11.0 and up to most recent
    if love.filesystem.getInfo(path, filtertype) then
      return true
    else
      error("Can't " .. debug.getinfo(2).name .. " \'" .. path .. "\': No such file or directory.")
    end
  else
    error("Love versions prior to 0.9.1 are not supported by this module..")
  end
end


return pathDefined
