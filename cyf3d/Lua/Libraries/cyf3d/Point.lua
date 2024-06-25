---@class Point
---@field x number
---@field y number
---@field z number
---@operator add({[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number}|Point|number):Point
---@operator sub({[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number}|Point|number):Point
local Point = {}

local indexMap = { 4, 5, 6, x = 4, y = 5, z = 6 }
function Point:__index(k)
  return Point[k] or self[indexMap[k] or k]
end

function Point:__newindex(k, v)
  self[indexMap[k] or k] = v
end

---@param p Point
function Point:addPoint(p)
  self[4] = self[4] + p[4]
  self[5] = self[5] + p[5]
  self[6] = self[6] + p[6]
end

---@param t {[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number}|Point
function Point:addTable(t)
  self[4] = self[4] + (t[1] or t.x)
  self[5] = self[5] + (t[2] or t.y)
  self[6] = self[6] + (t[3] or t.z)
end

---@param n number
function Point:addNumber(n)
  self[4] = self[4] + n
  self[5] = self[5] + n
  self[6] = self[6] + n
end

---@param x number
---@param y number
---@param z number
function Point:addCoords(x, y, z)
  self[4] = self[4] + x
  self[5] = self[5] + y
  self[6] = self[6] + z
end

---@overload fun(self: Point, t: {[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number})
---@overload fun(self: Point, x: number, y: number, z: number)
---@overload fun(self: Point, n: number)
function Point:add(...)
  local x, y, z = ...
  if type(x) == "table" then
    self[4] = self[4] + (x[1] or x.x)
    self[5] = self[5] + (x[2] or x.y)
    self[6] = self[6] + (x[3] or x.z)
    return
  end
  self[4] = self[4] + x
  self[5] = self[5] + (y or x)
  self[6] = self[6] + (z or x)
end

function Point:__add(obj)
  if type(obj) == "table" then
    x = self[4] + (obj[1] or obj.x)
    y = self[5] + (obj[2] or obj.y)
    z = self[6] + (obj[3] or obj.z)
  else
    x = self[4] + obj
    y = self[5] + obj
    z = self[6] + obj
  end
  return Point:new(x, y, z)
end

---@param p Point
function Point:subPoint(p)
  self[4] = self[4] - p[4]
  self[5] = self[5] - p[5]
  self[6] = self[6] - p[6]
end

---@param t {[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number}|Point
function Point:subTable(t)
  self[4] = self[4] - (t[1] or t.x)
  self[5] = self[5] - (t[2] or t.y)
  self[6] = self[6] - (t[3] or t.z)
end

---@param n number
function Point:subNumber(n)
  self[4] = self[4] - n
  self[5] = self[5] - n
  self[6] = self[6] - n
end

---@param x number
---@param y number
---@param z number
function Point:subCoords(x, y, z)
  self[4] = self[4] - x
  self[5] = self[5] - y
  self[6] = self[6] - z
end

---@overload fun(self: Point, t: {[1]:number,[2]:number,[3]:number}|{x:number,y:number,z:number})
---@overload fun(self: Point, x: number, y: number, z: number)
---@overload fun(self: Point, n: number)
function Point:sub(...)
  local x, y, z = ...
  if type(x) == "table" then
    self[4] = self[4] - (x[1] or x.x)
    self[5] = self[5] - (x[2] or x.y)
    self[6] = self[6] - (x[3] or x.z)
    return
  end
  self[4] = self[4] - x
  self[5] = self[5] - (y or x)
  self[6] = self[6] - (z or x)
end

function Point:__sub(obj)
  local x, y, z
  if type(x) == "table" then
    x = self[4] - (obj[1] or obj.x)
    y = self[5] - (obj[2] or obj.y)
    z = self[6] - (obj[3] or obj.z)
  else
    x = self[4] - obj
    y = self[5] - obj
    z = self[6] - obj
  end
  return Point:new(x, y, z)
end

---@param x number
---@param y number
---@param z number
---@return Point
---@nodiscard
function Point:new(x, y, z)
  local obj = { [4] = x, [5] = y, [6] = z }
  setmetatable(obj, self)
  return obj
end

return Point
