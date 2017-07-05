
--[[===============================================================================================

Colorable
---------------------------------------------------------------------------------------------------
An object with color properties.

=================================================================================================]]

-- Alias
local time = love.timer.getDelta
local yield = coroutine.yield

-- Constants
local colorf = Color.factor

local Colorable = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Initalizes color.
-- @param(color : table) a color table containing {red, green, blue, alpha} components (optional)
function Colorable:initColor(color)
  color = color or { red = 100, green = 100, blue = 100, alpha = 100 }
  self.color = color
  self.colorSpeed = 0
  self.origRed = color.red
  self.origGreen = color.green
  self.destRed = color.red
  self.destGreen = color.green
  self.colorTime = 1
  self.colorFiber = nil
  self.cropColor = true
  self.interruptableColor = true
end

-- Gets each RGBA component.
-- @ret(number) red compoent
-- @ret(number) green compoent
-- @ret(number) blue compoent
-- @ret(number) alpha compoent
function Colorable:getRGBA()
  return self.color.red, self.color.green, self.color.blue, self.color.alpha
end

-- Gets each RGBA multiplies by the color factor.
-- @ret(number) red compoent
-- @ret(number) green compoent
-- @ret(number) blue compoent
-- @ret(number) alpha compoent
function Colorable:getAbsoluteRGBA()
  return self.color.red * colorf, self.color.green * colorf, 
    self.color.blue * colorf, self.color.alpha * colorf
end

-- Sets color's rgb. If a component parameter is nil, it will not be changed.
-- @param(r : number) red component
-- @param(g : number) green component
-- @param(b : number) blue component
-- @param(a : number) alpha component
function Colorable:setRGBA(r, g, b, a)
  self.color.red = r or self.color.red
  self.color.green = g or self.color.green
  self.color.blue = b or self.color.blue
  self.color.alpha = a or self.color.alpha
end

-- Sets color's rgb.
-- @param(color : table) a color table containing {red, green, blue, alpha} components
function Colorable:setColor(color)
  self:setRGBA(color.red, color.green, color.blue, color.alpha)
end

---------------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------------

-- Applies color speed and updates color.
function Colorable:updateColor()
  if self.colorTime < 1 then
    self.colorTime = self.colorTime + self.colorSpeed * time()
    if self.moveTime > 1 and self.cropColor then
      self.colorTime = 1
    end
    local r = self.origRed * (1 - self.colorTime) + self.destRed * self.colorTime
    local g = self.origGreen * (1 - self.colorTime) + self.destGreen * self.colorTime
    local b = self.origBlue * (1 - self.colorTime) + self.destBlue * self.colorTime
    local a = self.origAlpha * (1 - self.colorTime) + self.destAlpha * self.colorTime
    if self:instantColorizeTo(r, g, b, a) and self.interruptableColor then
      self.colorTime = 1
    end
  end
end

-- [COROUTINE] Moves to (x, y).
-- @param(r : number) red component
-- @param(g : number) green component
-- @param(b : number) blue component
-- @param(a : number) alpha component
-- @param(speed : number) the speed of the colorizing (optional)
-- @param(wait : boolean) flag to wait until the colorizing finishes (optional)
function Colorable:colorizeTo(r, g, b, a, speed, wait)
  if speed and speed > 0 then
    self:gradativeColorizeTo(r, g, b, a, speed, wait)
  else
    self:instantColorizeTo(r, g, b, a)
  end
end

-- Colorizes instantly the object.
-- @param(r : number) red component
-- @param(g : number) green component
-- @param(b : number) blue component
-- @param(a : number) alpha component
-- @ret(boolean) true if the colorizing must be interrupted, nil or false otherwise
function Colorable:instantColorizeTo(r, g, b, a)
  self:setRGBA(r, g, b, a)
  return nil
end

-- [COROUTINE] Moves gradativaly (through updateMovement) to the given point.
-- @param(r : number) red component
-- @param(g : number) green component
-- @param(b : number) blue component
-- @param(a : number) alpha component
-- @param(speed : number) the speed of the colorizing
-- @param(wait : boolean) flag to wait until the colorizing finishes (optional)
function Colorable:gradativeColorizeTo(r, g, b, a, speed, wait)
  self.origRed, self.origGreen, self.origBlue, self.origAlpha = self:getRGBA()
  self.destRed, self.destGreen, self.destBlue, self.destAlpha = r, g, b, a
  self.colorTime = 0
  self.colorSpeed = speed
  if wait then
    self:waitForColor()
  end
end

-- [COROUTINE] Waits until the move time is 1.
function Colorable:waitForColor()
  local fiber = _G.Fiber
  if self.colorFiber then
    self.colorFiber:interrupt()
  end
  self.colorFiber = fiber
  while self.colorTime < 1 do
    yield()
  end
  if fiber:running() then
    self.colorFiber = nil
  end
end

return Colorable
