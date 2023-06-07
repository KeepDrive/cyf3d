Point = require("point")

Object = {}

function Object:new(obj)
  obj = obj or {}
  obj.pos = Point:new()
  obj.rotation = Point:new()
  obj.scale = Point:new({x = 1, y = 1, z = 1})
  setmetatable(obj, self)
  return obj
end

return Object
