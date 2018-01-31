
--[[===============================================================================================

Animation
---------------------------------------------------------------------------------------------------
An Animation updates the quad of the associated Sprite, assuming that the texture of the sprite 
is a spritesheet.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local TagMap = require('core/datastruct/TagMap')

-- Alias
local abs = math.abs
local mod = math.mod
local sign = math.sign
local deltaTime = love.timer.getDelta
local Quad = love.graphics.newQuad

local Animation = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- @param(sprite : Sprite) the sprite that this animation if associated to
function Animation:init(sprite, data)
  -- Current quad indexes col/row in the spritesheet
  self.col = 0
  self.row = 0
  self.sprite = sprite
  self.data = data
  -- Frame count (adapted to the frame rate)
  self.time = 0
  self.speed = 1
  self.paused = sprite == nil
  if data and data.animation then
    -- The size of each quad
    self.quadWidth = data.width / data.cols
    self.quadHeight = data.height / data.rows
    -- Number of rows and collunms of the spritesheet
    self.colCount = data.cols
    self.rowCount = data.rows
    -- Loop type
    self.loop = data.animation.loop
    -- Duration
    self:setTiming(data.animation.duration, data.animation.timing)
    -- Tags
    if data.tags and #data.tags > 0 then
      self.tags = TagMap(data.tags)
    end
    self.param = data.animation.script.param
  else
    if sprite and sprite.texture then
      self.quadWidth = sprite.texture:getWidth()
      self.quadHeight = sprite.texture:getHeight()
    end
    self.colCount = 1
    self.rowCount = 1
    self.loop = 0
  end
end
-- Creates a clone of this animation.
-- @param(sprite : Sprite) the sprite of the animation, if cloned too (optional)
-- @ret(Animation)
function Animation:clone(sprite)
  local anim = Animation(sprite or self.sprite, self.data)
  anim.col = self.col
  anim.row = self.row
  anim.paused = self.paused
  anim.time = self.time
  anim.speed = self.speed
  return anim
end
-- Sets the time for each frame. 
-- If timing is nil and duration is 0, animation is set as static.
-- @param(duration : number) total duration of the animation
-- @param(timing : table) array of frame times, one element per frame
function Animation:setTiming(duration, timing)
  self.frameTime = nil
  if duration and duration > 0 then
    self.frameTime = {}
    for i = 1, self.colCount do
      self.frameTime[i - 1] = duration / self.colCount
    end
  end
  if timing then
    self.frameTime = self.frameTime or {}
    for i = 1, self.colCount do
      self.frameTime[i - 1] = timing[i] or self.frameTime[i - 1]
    end
  end
  if self.frameTime then
    self.duration = 0
    for i = 1, self.colCount do
      assert(self.frameTime[i - 1], 'Frame time not defined: ' .. i)
      self.duration = self.duration + self.frameTime[i - 1]
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------------

-- Increments the frame count and automatically changes que sprite.
function Animation:update()
  if self.paused or not self.duration or not self.frameTime then
    return
  end
  self.time = self.time + deltaTime() * 60 * abs(self.speed)
  if self.time >= self.frameTime[self.col] then
    self.time = self.time - self.frameTime[self.col]
    self:nextFrame()
  end
end
-- Sets to next frame.
function Animation:nextFrame()
  local lastCol = 0
  if self.speed > 0 then
    lastCol = self.colCount - 1
  end
  if self.col ~= lastCol then
    self:nextCol()
  else
    self:onEnd()
  end
end
-- What happens when the animations finishes.
function Animation:onEnd()
  if self.loop == 0 then
    self.paused = true
  elseif self.loop == 1 then
    self:nextCol()
  elseif self.loop == 2 then
    self.speed = -self.speed
    if self.colCount > 1 then
      self:nextCol()
    end
  end
end
-- Sets to the next column.
function Animation:nextCol()
  self:setCol(self.col + sign(self.speed))
end
-- Sets to the next row.
function Animation:nextRow()
  self:setRow(self.row + sign(self.speed))
end
-- Changes the column of the current quad
-- @param(col : number) the column number, starting from 0
function Animation:setCol(col)
  col = mod(col, self.colCount)
  if self.col ~= col then
    local x, y, w, h = self.sprite.quad:getViewport()
    x = x + (col - self.col) * self.quadWidth
    self.col = col
    self.sprite.quad:setViewport(x, y, w, h)
    self.sprite.renderer.needsRedraw = true
  end
end
-- Changes the row of the current quad
-- @param(row : number) the row number, starting from 0
function Animation:setRow(row)
  row = mod(row, self.rowCount)
  if self.row ~= row then
    local x, y, w, h = self.sprite.quad:getViewport()
    y = y + (row - self.row) * self.quadHeight
    self.row = row
    self.sprite.quad:setViewport(x, y, w, h)
    self.sprite.renderer.needsRedraw = true
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

function Animation:reset()
  self.time = 0
  self:setCol(0)
  self:setRow(0)
end
-- Destroy this animation.
function Animation:destroy()
  if self.sprite then
    self.sprite:destroy()
  end
end
-- Sets the sprite's visibility.
-- @param(value : boolean)
function Animation:setVisible(value)
  self.sprite:setVisible(value)
end
-- Sets this animation as visible.
function Animation:show()
  self.sprite:setVisible(true)
end
-- Sets this animation as invisible.
function Animation:hide()
  self.sprite:setVisible(false)
end
-- String representation.
-- @ret(string)
function Animation:__tostring()
  local id = ''
  if self.data then
    id = ' (' .. self.data.id .. ')'
  end
  return 'Animation' .. id
end

return Animation
