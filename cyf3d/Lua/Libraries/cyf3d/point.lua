local Point = {}

function Point:__index(key)
  return self._point[key] or Point[key]
end

function Point:__newindex(key, value)
  self.updated = true
  self._point[key] = value
end

local sqrt = math.sqrt

function Point.__add(lhs, rhs)
--#DEBUG
  assert(type(rhs) == "table", "Attempt to use point addition with unsupported object")
--#DEBUGEND
  local new = Point:new()
  local newPt = new._point
  local lhsPt = lhs._point
  local rhsPt = rhs._point or rhs
  newPt.x = lhsPt.x + (rhsPt.x or rhsPt[1])
  newPt.y = lhsPt.y + (rhsPt.y or rhsPt[2])
  newPt.z = lhsPt.z + (rhsPt.z or rhsPt[3])
  return new
end

function Point.__sub(lhs, rhs)
--#DEBUG
  assert(type(rhs) == "table", "Attempt to use point subtraction with unsupported object")
--#DEBUGEND
  local new = Point:new()
  local newPt = new._point
  local lhsPt = lhs._point
  local rhsPt = rhs._point or rhs
  newPt.x = lhsPt.x - (rhsPt.x or rhsPt[1])
  newPt.y = lhsPt.y - (rhsPt.y or rhsPt[2])
  newPt.z = lhsPt.z - (rhsPt.z or rhsPt[3])
  return new
end

function Point:__mul(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to multiply point by non-number")
--#DEBUGEND
  local new = Point:new()
  local newPt = new._point
  local selfPt = self._point
  newPt.x = selfPt.x * num
  newPt.y = selfPt.y * num
  newPt.z = selfPt.z * num
  return new
end

function Point:__div(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to divide point by non-number")
--#DEBUGEND
  local new = Point:new()
  local newPt = new._point
  local selfPt = self._point
  local oneOver = 1 / num
  newPt.x = selfPt.x * oneOver
  newPt.y = selfPt.y * oneOver
  newPt.z = selfPt.z * oneOver
  return new
end

function Point:__eq(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to compare point with unsupported object")
--#DEBUGEND
  local selfPt = self._point
  local objPt = obj._point or obj
  local equalsX = (selfPt.x == (objPt.x or objPt[1]))
  local equalsY = (selfPt.y == (objPt.y or objPt[2]))
  local equalsZ = (selfPt.z == (objPt.z or objPt[3]))
  return equalsX and equalsY and equalsZ
end

function Point:squareVectorLength()
  local selfPt = self._point
  return selfPt.x ^ 2 + selfPt.y ^ 2 + selfPt.z ^ 2
end

function Point:vectorLength()
  return sqrt(self:squareVectorLength())
end

function Point:squareDistanceTo(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to get distance to unsupported object")
--#DEBUGEND
  local selfPt = self._point
  local objPt = obj._point or obj
  local xDist = (objPt.x or objPt[1]) - selfPt.x
  local yDist = (objPt.y or objPt[2]) - selfPt.y
  local zDist = (objPt.z or objPt[3]) - selfPt.z
  return xDist ^ 2 + yDist ^ 2 + zDist ^ 2
end

function Point:distanceTo(obj)
  return sqrt(self:squareDistanceTo(obj))
end

function Point:set(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to get distance to unsupported object")
--#DEBUGEND
  local selfPt = self._point
  local objPt = obj._point or obj
  selfPt.x = (objPt.x or objPt[1])
  selfPt.y = (objPt.y or objPt[2])
  selfPt.z = (objPt.z or objPt[3])
  self.updated = true
end

function Point:add(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to use point addition with unsupported object")
--#DEBUGEND
  local selfPt = self._point
  local objPt = obj._point or obj
  selfPt.x = selfPt.x + (objPt.x or objPt[1])
  selfPt.y = selfPt.y + (objPt.y or objPt[2])
  selfPt.z = selfPt.z + (objPt.z or objPt[3])
  self.updated = true
end

function Point:subtract(obj)
--#DEBUG
  assert(type(obj) == "table", "Attempt to use point subtraction with unsupported object")
--#DEBUGEND
  local selfPt = self._point
  local objPt = obj._point or obj
  selfPt.x = selfPt.x - (objPt.x or objPt[1])
  selfPt.y = selfPt.y - (objPt.y or objPt[2])
  selfPt.z = selfPt.z - (objPt.z or objPt[3])
  self.updated = true
end

function Point:multiply(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to multiply point by non-number")
--#DEBUGEND
  local selfPt = self._point
  selfPt.x = selfPt.x * num
  selfPt.y = selfPt.y * num
  selfPt.z = selfPt.z * num
end

function Point:divide(num)
--#DEBUG
  assert(type(num) == "number", "Attempt to divide point by non-number")
--#DEBUGEND
  local selfPt = self._point
  local oneOver = 1 / num
  selfPt.x = selfPt.x * oneOver
  selfPt.y = selfPt.y * oneOver
  selfPt.z = selfPt.z * oneOver
end

function Point:new(obj)
  obj = obj or {}
  obj._point = {x = 0, y = 0, z = 0}
  obj.updated = true
  setmetatable(obj, self)
  return obj
end

return Point
