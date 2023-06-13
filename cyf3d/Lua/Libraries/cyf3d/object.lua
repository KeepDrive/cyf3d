Point = require("point")

Object = {}
Object.__index = Object

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
  self.pos:set(newPos)
end

function Object:rotate(deltaRotation)
  self.rotation = self.rotation + deltaRotation
end

function Object:rotateTo(newRotation)
  self.rotation:set(newRotation)
end

function Object:setScale(newScale)
  self.scale:set(newScale)
end

return Object
