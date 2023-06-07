local Point = {x = 0, y = 0, z = 0}
Point.__index = Point

function Point.__add(lhs, rhs)
--#DEBUG
  assert(type(rhs) == "table", "Attempt to use point addition with unsupported object")
--#DEBUGEND
  local new = Point:new()
  new.x = lhs.x + (rhs.x or rhs[1])
  new.y = lhs.y + (rhs.y or rhs[2])
  new.z = lhs.z + (rhs.z or rhs[3])
  return new
end

function Point.__sub(lhs, rhs)
--#DEBUG
  assert(type(rhs) == "table", "Attempt to use point subtraction with unsupported object")
--#DEBUGEND
  local new = Point:new()
  new.x = lhs.x - (rhs.x or rhs[1])
  new.y = lhs.y - (rhs.y or rhs[2])
  new.z = lhs.z - (rhs.z or rhs[3])
  return new
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
