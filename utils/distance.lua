local distance = function(point1, point2)
  local px, py, dist
  px = math.abs(point1.x - point2.x)
  py = math.abs(point1.y - point2.y)
  dist = math.sqrt((px * px) + (py * py))

  return dist
end

return distance
