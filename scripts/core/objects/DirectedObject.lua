
--[[===============================================================================================

DirectedObject
---------------------------------------------------------------------------------------------------
An object with a direction.

=================================================================================================]]

-- Imports
local AnimatedObject = require('core/objects/AnimatedObject')

-- Alias
local angle2Row = math.angle2Row
local coord2Angle = math.coord2Angle
local nextCoordDir = math.field.nextCoordDir
local tile2Pixel = math.field.tile2Pixel
local abs = math.abs

local DirectedObject = class(AnimatedObject)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Overrides AnimatedObject:initGraphics.
-- @param(direction : number) the initial direction
function DirectedObject:initGraphics(animations, direction, anim, transform)
  self.direction = direction
  AnimatedObject.initGraphics(self, animations, anim, transform)
  self:setDirection(direction)
end

---------------------------------------------------------------------------------------------------
-- Direction
---------------------------------------------------------------------------------------------------

-- Overrides AnimatedObject:replayAnimation.
function DirectedObject:replayAnimation(name, wait, row)
  row = row or angle2Row(self.direction)
  return AnimatedObject.replayAnimation(self, name, wait, row)
end
-- Set's character direction
-- @param(angle : number) angle in degrees
function DirectedObject:setDirection(angle)
  self.direction = angle
  self.animation:setRow(angle2Row(angle))
end
-- Gets the direction rounded to one of the canon angles.
-- @ret(number) Direction in degrees.
function DirectedObject:getRoundedDirection()
  local row = angle2Row(self.direction)
  return row * 45
end
-- The tile on front of the character, considering character's direction.
-- @ret(ObjectTile) the front tile (nil if exceeds field border)
function DirectedObject:frontTile(angle)
  angle = angle or self:getRoundedDirection()
  local dx, dy = nextCoordDir(angle)
  local tile = self:getTile()
  if FieldManager.currentField:exceedsBorder(tile.x + dx, tile.y + dy) then
    return nil
  else
    return tile.layer.grid[tile.x + dx][tile.y + dy]
  end
end

---------------------------------------------------------------------------------------------------
-- Rotate
---------------------------------------------------------------------------------------------------

-- Turns on a vector's direction (in pixel coordinates).
-- @param(x : number) vector's x
-- @param(y : number) vector's y
-- @ret(number) the angle to the given vector
function DirectedObject:turnToVector(x, y)
  local angle = self:vectorToAngle(x, y)
  self:setDirection(angle)
  return angle
end
-- Turns to a pixel point.
-- @param(x : number) the pixel x
-- @param(y : number) the pixel y
-- @ret(number) the angle to the given point
function DirectedObject:turnToPoint(x, y)
  local angle = self:pointToAngle(x, y)
  self:setDirection(angle)
  return angle
end
-- Turns to a grid point.
-- @param(x : number) the tile x
-- @param(y : number) the tile y
-- @ret(number) the angle to the given tile
function DirectedObject:turnToTile(x, y)
  local angle = self:tileToAngle(x, y)
  self:setDirection(angle)
  return angle
end

---------------------------------------------------------------------------------------------------
-- Get angle
---------------------------------------------------------------------------------------------------

-- Gets the angle in the direction given by the vector
-- @param(x : number) vector's x
-- @param(y : number) vector's y
-- @ret(number) the angle to the given vector
function DirectedObject:vectorToAngle(x, y)
  if abs(x) > 0.01 or abs(y) > 0.01 then
    return coord2Angle(x, y)
  else
    return self.direction
  end
end
-- Gets the angle to a given pixel point.
-- @param(x : number) the pixel x
-- @param(y : number) the pixel y
-- @ret(number) the angle to the given point
function DirectedObject:pointToAngle(x, y)
  local dx = x - self.position.x
  local dy = y + self.position.z
  return self:vectorToAngle(dx, dy)
end
-- Gets the angle to a given grid point.
-- @param(x : number) the tile x
-- @param(y : number) the tile y
-- @ret(number) the angle to the given tile
function DirectedObject:tileToAngle(x, y)
  local h = self:getTile().layer.height
  local destx, desty, destz = tile2Pixel(x, y, h)
  return self:pointToAngle(destx, -destz)
end

return DirectedObject
