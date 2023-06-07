local Point = {x = 0, y = 0, z = 0}
Point.__index = Point

function Point:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  return obj
end

return Point
