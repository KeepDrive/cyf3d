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

function Object:move(deltaPos)
  self.pos = self.pos + deltaPos
end

function Object:moveTo(newPos)
  self.pos = Point:new(newPos)
end

return Object
