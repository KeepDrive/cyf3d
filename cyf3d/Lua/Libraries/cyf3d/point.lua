local Point = {x = 0, y = 0, z = 0}
Point.__index = Point

function Point:__add(obj)
  local objType = type(obj)
  if objType == "number" then
    self.x = self.x + obj
    self.y = self.y + obj
    self.z = self.z + obj
  elseif objType == "table" then
    self.x = self.x + (obj.x or obj[1])
    self.y = self.y + (obj.y or obj[2])
    self.z = self.z + (obj.z or obj[3])
--DEBUG
  else
    error("Attempt to combine point with unsupported object")
--DEBUGEND
  end
end

function Point:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  return obj
end

return Point
