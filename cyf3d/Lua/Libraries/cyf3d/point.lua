local Point = {x = 0, y = 0, z = 0}
Point.__index = Point

local sqrt = math.sqrt

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

function Point:__mul(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to multiply point by non-number")
--#DEBUGEND
  local new = Point:new()
  new.x = self.x * num
  new.y = self.y * num
  new.z = self.z * num
  return new
end

function Point:__div(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to divide point by non-number")
--#DEBUGEND
  local new = Point:new()
  new.x = self.x * num
  new.y = self.y * num
  new.z = self.z * num
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

function Point:squareVectorLength()
  return self.x ^ 2 + self.y ^ 2 + self.z ^ 2
end

function Point:vectorLength()
  return sqrt(self:squareVectorLength())
end

function Point:squareDistanceTo(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to get distance to unsupported object")
--#DEBUGEND
  local xDist = (obj.x or obj[1]) - self.x
  local yDist = (obj.y or obj[2]) - self.y
  local zDist = (obj.z or obj[3]) - self.z
  return xDist ^ 2 + yDist ^ 2 + zDist ^ 2
end

function Point:distanceTo(obj)
  return sqrt(self:squareDistanceTo(obj))
end

function Point:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  return obj
end

return Point
