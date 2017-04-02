
--[[===========================================================================

Vector
-------------------------------------------------------------------------------
An offset in three-dimensional space. 
It consists of an x, and a y component,
each being an offset along a different orthogonal axis.

=============================================================================]]

-- Alias
local floor = math.floor
local ceil = math.ceil
local round = math.round
local rotate = math.rotate
local min = math.min
local max = math.max

local Vector = require('core/class'):new()

-- @param(x : number) the x coordinate of the Vector
-- @param(y : number) the y coordinate of the Vector
-- @param(z : number) the z coordinate of the Vector (default: 0)
function Vector:init(x,y,z)
  self.x = x
  self.y = y
  self.z = z or 0
end

function Vector:equals(x, y, z)
  return self.x == x and self.y == y and self.z == z
end

function Vector:isZero()
  return self.x == 0 and self.y == 0 and self.z == 0
end

-- Adds other Vector to this Vector
-- @param(other : Vector) the vector to be added
-- @ret(Vector) to result of the sum as a new vector
function Vector:__add(other)
  return Vector(self.x + other.x, self.y + other.y, self.z + other.z)
end

function Vector:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  self.z = self.z + other.z
end
   
-- Subtracts other Vector from this Vector.
-- @param(other : Vector) the vector to be subtracted
-- @ret(Vector) the result of the substraction as a new vector
function Vector:__sub(other)
  return Vector(self.x - other.x, self.y - other.y, self.z - other.z)
end

function Vector:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  self.z = self.z - other.z
end

-- Scales this vector by a scalar
-- @param(scalar : number) the scalar to scale by
-- @ret(Vector) the result of the scaling as a new vector
function Vector:__mul(scalar)
  return Vector(self.x * scalar, self.y * scalar, self.z * scalar)
end

function Vector:mul(scalar)
  self.x = self.x * scalar
  self.y = self.y * scalar
  self.z = self.z * scalar
end

-- Calculates the negation of this vector.
-- @ret(Vector) the negation as a new vector
function Vector:__unm()
  return Vector(-self.x,-self.y-self.z)
end

function Vector:unm()
  self.x = -self.x
  self.y = -self.y
  self.z = -self.z
end

-- Calculares the perpendicular vector to this vector.
-- @ret(Vector) the result as a new vector
function Vector:perp()
  return Vector(-self.y,self.x,self.z)
end

-- Returns the coordinates of the Vector as separate values.
-- @ret(number) The x coordinate of the Vector
-- @ret(number) The y coordinate of the Vector
-- @ret(number) The z coordinate of the Vector
function Vector:coordinates()
  return self.x, self.y, self.z
end

-- Creates a new vector that is the copy of this one.
-- @ret(Vector) the clone vector
function Vector:clone()
  return Vector(self.x, self.y, self.z)
end

-- Calculares the length of the vector.
--@ret(number) the length
function Vector:len()
  return math.sqrt(self.x*self.x+self.y*self.y+self.z*self.z)
end

function Vector:len2D()
  return math.len2D(self.x, self.y, self.z)
end

-- Rotate this Vector phi radians counterclockwise.
-- @param(phi : number) the number of radians counterclockwise to rotate the Vector
function Vector:rotate(phi)
	self.x, self.y = rotate(self.x, self.y, phi)
end

-- Rotates this Vector phi radians counterclockwise.
-- @param(phi : number) Number of radians to rotate counterclockwise
-- @ret(Vector) the vector rotated by phi radians counterclockwise as a new vector
function Vector:rotated(phi)
	local clone = Vector(self.x,self.y,self.z)
  clone:rotate(phi)
  return clone
end

-- Normalizes this Vector.
function Vector:normalize()
  --local z = self.z
  --self.z = 0
	local l = self:len()
  self.x = self.x / l
  self.y = self.y / l
  self.z = self.z / l
end

-- Normalizes this Vector.
-- @ret(Vector) this Vector normalized as a new vector
function Vector:normalized()
	local clone = Vector(self.x,self.y,self.z)
  clone:normalize()
  return clone
end

-- Linearlly interpolates this vector with other.
-- @param(other : Vector) vector in time = 1
-- @param(time : number) the time between 0 and 1
-- @ret(Vector) the result of the interpolation
function Vector:lerp(other, time)
  time = max(time, 0)
  time = min(1, time)
  return self * (1 - time) + other * time
end

-- Rounds this vector's coordinates.
function Vector:round()
  self.x = round(self.x)
  self.y = round(self.y)
  self.z = round(self.z)
end

-- Rounds this vector's coordinates.
-- @ret(Vector) this vector rounded as a new vector
function Vector:rounded()
  return Vector(round(self.x), round(self.y), round(self.z))
end

function Vector:floor()
  self.x = floor(self.x)
  self.y = floor(self.y)
  self.z = floor(self.z)
end

function Vector:floored()
  return Vector(floor(self.x), floor(self.y), floor(self.z))
end

function Vector:ceil()
  self.x = floor(self.x)
  self.y = floor(self.y)
  self.z = floor(self.z)
end

function Vector:ceiled()
  return Vector(ceil(self.x), ceil(self.y), ceil(self.z))
end

-- Converting to string.
-- @ret(string) A string representation
function Vector:toString()
  return '<' .. self.x .. ',' .. self.y .. ',' .. self.z .. '>'
end

return Vector
