-- LogManagerColor.lua
local LogManagerColor = {}

-- ANSI color codes
LogManagerColor.colors = {
  reset = 0,
  black = 30,
  red = 31,
  green = 32,
  yellow = 33,
  blue = 34,
  magenta = 35,
  cyan = 36,
  white = 37,

  -- Bright versions
  bright_black = 90,
  bright_red = 91,
  bright_green = 92,
  bright_yellow = 93,
  bright_blue = 94,
  bright_magenta = 95,
  bright_cyan = 96,
  bright_white = 97
}

-- Format a single string with a color
function LogManagerColor.colorText(text, colorName)
  local code = LogManagerColor.colors[colorName]
  if not code then
    return text -- fallback: no color
  end
  return string.format("\27[%dm%s\27[0m", code, text)
end

-- Fancy color formatting with {color} tags
function LogManagerColor.colorf(str)
  -- Replace {color} with the correct ANSI code
  local formatted = str:gsub("{(.-)}", function(colorName)
    local code = LogManagerColor.colors[colorName]
    if code then
      return string.format("\27[%dm", code)
    else
      return "{" .. colorName .. "}" -- Leave it unchanged if unknown
    end
  end)
  -- Ensure reset at the very end
  formatted = formatted .. "\27[0m"
  return formatted
end

return LogManagerColor
