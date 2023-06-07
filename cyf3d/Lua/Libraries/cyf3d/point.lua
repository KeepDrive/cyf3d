local Point = {x = 0, y = 0, z = 0}
Point.__index = Point

function Point:__add(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to use point addition with unsupported object")
--#DEBUGEND
  self.x = self.x + (obj.x or obj[1])
  self.y = self.y + (obj.y or obj[2])
  self.z = self.z + (obj.z or obj[3])
end

function Point:__sub(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to use point subtraction with unsupported object")
--#DEBUGEND
  self.x = self.x - (obj.x or obj[1])
  self.y = self.y - (obj.y or obj[2])
  self.z = self.z - (obj.z or obj[3])
end

function Point:__eq(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to compare point with unsupported object")
--#DEBUGEND
  local equalsX = (self.x == (obj.x or obj[1]))
  local equalsY = (self.y == (obj.y or obj[2]))
  local equalsZ = (self.z == (obj.z or obj[3]))
  return equalsX and equalsY and equalsZ
end

function Point:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  return obj
end

return Point
