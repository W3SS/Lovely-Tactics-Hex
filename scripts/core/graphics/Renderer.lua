
--[[===============================================================================================

Renderer
---------------------------------------------------------------------------------------------------
A Renderer manages a list of sprites to be rendered. 
Stores them in order and draws them using a batch.

=================================================================================================]]

-- Imports
local List = require('core/datastruct/List')
local Transformable = require('core/transform/Transformable')

-- Alias
local lgraphics = love.graphics
local round = math.round
local rotate = math.rotate

-- Constants
local blankTexture = lgraphics.newImage(love.image.newImageData(1, 1))
local spriteShader = lgraphics.newShader('shaders/Sprite.glsl')

local Renderer = class(Transformable)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(size : number) the max number of sprites.
-- @param(minDepth : number) the minimun depth of a sprite
-- @param(maxDepth : number) the maximum depth of a sprite
function Renderer:init(size, minDepth, maxDepth, order)
  Transformable.init(self)
  self.minDepth = minDepth
  self.maxDepth = maxDepth
  self.size = size
  self.list = {}
  self.batch = lgraphics.newSpriteBatch(blankTexture, size, 'dynamic')
  self.canvas = lgraphics.newCanvas(1, 1)
  self.order = order
  self.batchHSV = {0, 1, 1}
  self.minx = -math.huge
  self.maxx = math.huge
  self.miny = -math.huge
  self.maxy = math.huge
  self:activate()
  self:resizeCanvas()
end
-- Resize canvas acording to the zoom.
function Renderer:resizeCanvas()
  local newW = ScreenManager.width * ScreenManager.scaleX
  local newH = ScreenManager.height * ScreenManager.scaleY
  if newW ~= self.canvas:getWidth() or newH ~= self.canvas:getHeight() then
    self.canvas = lgraphics.newCanvas(newW, newH)
    self.needsRedraw = true
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Inserts self in the screen renderers.
function Renderer:activate()
  ScreenManager.renderers[self.order] = self
end
-- Removes self from the screen renderers.
function Renderer:deactivate()
  ScreenManager.renderers[self.order] = nil
end
function Renderer:spriteCount()
  local count = 0
  for i = self.minDepth, self.maxDepth do
    if self.list[i] then
      count = count + #self.list[i]
    end
  end
  return count
end

---------------------------------------------------------------------------------------------------
-- Position convertion
---------------------------------------------------------------------------------------------------

-- Converts a screen point to a world point.
-- @param(x : number) the screen x
-- @param(y : number) the screen y
-- @ret(number) world x
-- @ret(number) world y
function Renderer:screen2World(x, y)
  -- Canvas center
  local ox = ScreenManager.width / 2
  local oy = ScreenManager.height / 2
  -- Total scale
  local sx = ScreenManager.scaleX * self.scaleX
  local sy = ScreenManager.scaleY * self.scaleY
  -- Screen black border offset
  x, y = x - ScreenManager.offsetX, y - ScreenManager.offsetY
  -- Set to origin
  x = x + (self.position.x - ox) * sx
  y = y + (self.position.y - oy) * sy
  -- Revert Transformation
  x, y = x - ox * sx, y - oy * sy
  x, y = rotate(x, y, -self.rotation)
  x, y = x / sx, y / sy
  x, y = x + ox, y + oy
  return x, y
end
-- Converts a world point to a screen point.
-- @param(x : number) the world x
-- @param(y : number) the world y
-- @ret(number) screen x
-- @ret(number) screen y
function Renderer:world2Screen(x, y)
  -- Canvas center
  local ox = ScreenManager.width / 2
  local oy = ScreenManager.height / 2
  -- Total scale
  local sx = ScreenManager.scaleX * self.scaleX
  local sy = ScreenManager.scaleY * self.scaleY
  -- Apply Transformation
  x, y = x - ox, y - oy
  x, y = x * sx, y * sy
  x, y = rotate(x, y, self.rotation)
  x, y = x + ox * sx, y + oy * sy
  -- Set to position
  x = x - (self.position.x - ox) * sx
  y = y - (self.position.y - oy) * sy
  -- Screen black border offset
  x, y = x + ScreenManager.offsetX, y + ScreenManager.offsetY
  return x, y
end

---------------------------------------------------------------------------------------------------
-- Transformations
---------------------------------------------------------------------------------------------------

-- Sets Renderer's center position in the world coordinates.
-- @param(x : number) pixel x
-- @param(y : number) pixel y
function Renderer:setXYZ(x, y, z)
  x = round(x)
  y = round(y)
  if self.position.x ~= x or self.position.y ~= y then
    Transformable.setXYZ(self, x, y, 0)
    self.needsRedraw = true
  end
end
-- Sets Renderer's zoom. 1 is normal.
-- @param(zoom : number) new zoom
function Renderer:setZoom(zoom)
  if self.scaleX ~= zoom or self.scaleY ~= zoom then
    self:setScale(zoom, zoom)
    self.needsRedraw = true
  end
end
-- Sets Renderer's rotation.
-- @param(angle : number) rotation in degrees
function Renderer:setRotation(angle)
  if angle ~= self.rotation then
    self.rotation = angle
    self.needsRedraw = true
  end
end

---------------------------------------------------------------------------------------------------
-- Draw
---------------------------------------------------------------------------------------------------

-- Draws all sprites in the renderer's table.
function Renderer:draw()
  if self.needsRedraw then
    self:redrawCanvas()
  end
  local r, g, b, a = lgraphics.getColor()
  local shader = lgraphics.getShader()
  lgraphics.setColor(self:getRGBA())
  spriteShader:send('phsv', {self:getHSV()})
  lgraphics.draw(self.canvas, 0, 0)
  lgraphics.setColor(r, g, b, a)
end
-- Draws all sprites in the table to the canvas.
function Renderer:redrawCanvas()
  -- Center of the canvas
  self.toDraw = List()
  local ox = round(self.canvas:getWidth() / 2)
  local oy = round(self.canvas:getHeight() / 2)
  local sx = ScreenManager.scaleX * self.scaleX
  local sy = ScreenManager.scaleY * self.scaleY
  local firstCanvas = lgraphics.getCanvas()
  local firstShader = lgraphics.getShader()
  lgraphics.setShader(spriteShader)
  lgraphics.push()
  lgraphics.setCanvas(self.canvas)
  lgraphics.translate(-ox, -oy)
  lgraphics.scale(sx, sy)
  lgraphics.rotate(self.rotation)
  lgraphics.translate(-self.position.x + ox * 2 / sx, -self.position.y + oy * 2 / sy)
  lgraphics.clear()
  local started = false
  local w, h = ScreenManager.width * self.scaleX / 2, ScreenManager.height * self.scaleY / 2
  self.minx, self.maxx = self.position.x - w, self.position.x + w
  self.miny, self.maxy = self.position.y - h, self.position.y + h
  for i = self.maxDepth, self.minDepth, -1 do
    local list = self.list[i]
    if list then
      if not started then
        self.batchTexture = blankTexture
        self.batch:setTexture(blankTexture)
        started = true
      end
      self:drawList(list)
    end
  end
  self:clearBatch()
  lgraphics.setCanvas(firstCanvas)
  lgraphics.setShader(firstShader)
  lgraphics.pop()
  self.toDraw = nil
  self.needsRedraw = false
end
-- Draws all sprites in the same depth.
-- @param(list : Sprite Table) the list of sprites to be drawn
function Renderer:drawList(list)
  local n = #list
  for i = 1, n do
    local sprite = list[i]
    if sprite:isVisible() then
      if sprite.needsRecalcBox then
        sprite:recalculateBox()
      end
      if sprite.position.x - sprite.diag < self.maxx and 
          sprite.position.x + sprite.diag > self.minx and
          sprite.position.y - sprite.diag < self.maxy and 
          sprite.position.y + sprite.diag > self.miny then
        sprite:draw(self)
      end
    end
  end
end
-- Draws current and clears.
function Renderer:clearBatch()
  if self.batch and self.toDraw.size > 0 then
    spriteShader:send('phsv', self.batchHSV)
    self.batch:setTexture(self.batchTexture)
    lgraphics.draw(self.batch)
    self.batch:clear()
    self.toDraw.size = 0
  end
end
-- Organizes current sprite list by texture.
-- @param(list : Sprite Table) list of sprites to be sorted
function Renderer:sortList(list)
  local texture = self.batch:getTexture()
  local hsv = self
  local n = #list
  local l = 1
  local r = n
  repeat
    while l < r do
      while list[r].texture ~= texture and l < r do
        r = r - 1
      end
      while list[l].texture == texture and l < r do
        l = l + 1
      end
      if l <= r then
        list[l], list[r] = list[r], list[l]
        r = r - 1
        l = l + 1
      end
    end
    if l < r then
      texture = list[l].texture
      r = n
    end
  until l >= r
end

function Renderer:batchPossible(sprite)
  if sprite.texture ~= self.batchTexture then
    return false
  end
  local hsv1, hsv2 = sprite.hsv, self.batchHSV
  return hsv1.h == hsv2[1] and hsv1.s == hsv2[2] and hsv1.v == hsv2[3]
end

return Renderer
