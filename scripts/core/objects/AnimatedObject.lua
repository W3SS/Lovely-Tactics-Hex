
--[[===============================================================================================

AnimatedObject
---------------------------------------------------------------------------------------------------
An object with a table of animations.

=================================================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local Animation = require('core/graphics/Animation')
local Object = require('core/objects/Object')

-- Alias
local mathf = math.field
local Quad = love.graphics.newQuad

local AnimatedObject = class(Object)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Creates sprite and animation list.
-- @param(animations : table) an array of animation data
-- @param(animID : number) the start animation's ID
function AnimatedObject:initGraphics(animations, initAnim, transform)
  self.animName = nil
  self.transform = transform
  self.sprite = Sprite(FieldManager.renderer)
  self:initAnimationTable(animations)
  if initAnim then
    self:playAnimation(initAnim)
  end
end
-- Creates the animation table from the animation list.
-- @param(animations : table) array of animations
function AnimatedObject:initAnimationTable(animations)
  self.animationData = {}
  for name, id in pairs(animations) do
    self:addAnimation(name, id)
  end
end
-- Creates a new animation from the database.
-- @param(name : string) the name of the animation for the character
-- @param(id : number) the animation's ID in the database
function AnimatedObject:addAnimation(name, id)
  local data = Database.animations[id]
  local animation = ResourceManager:loadAnimation(data, self.sprite)
  local quad, texture = ResourceManager:loadQuad(data)
  self.animationData[name] = {
    transform = data.transform,
    animation = animation,
    texture = texture,
    quad = quad }
end

---------------------------------------------------------------------------------------------------
-- Play
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Plays an animation by name, ignoring if the animation is already playing.
-- @param(name : string) animation's name
-- @param(wait : boolean) true to wait until first loop finishes (optional)
-- @ret(Animation)
function AnimatedObject:playAnimation(name, wait, row)
  if self.animName == name then
    return self.animation
  else
    return self:replayAnimation(name, wait, row)
  end
end
-- [COROUTINE] Plays an animation by name.
-- @param(name : string) animation's name (optional; current animation by default)
-- @param(wait : boolean) true to wait until first loop finishes (optional)
-- @ret(Animation)
function AnimatedObject:replayAnimation(name, wait, row)
  name = name or self.animName
  local data = self.animationData[name]
  assert(data, "Animation does not exist: " .. name)
  self.animName = name
  local anim = data.animation
  self.sprite.quad = data.quad
  self.sprite:setTexture(data.texture)
  self.sprite:setTransformation(data.transform)
  self.sprite:applyTransformation(self.transform)
  if self.statusTransform then
    self.sprite:applyTransformation(self.statusTransform)
  end
  self.animation = anim
  anim.sprite = self.sprite
  if row then
    anim:setRow(row)
  end
  anim.paused = false
  if wait and anim.duration then
    _G.Fiber:wait(anim.duration)
  end
  return anim
end
-- Updates animation.
function AnimatedObject:update()
  Object.update(self)
  if self.animation then
    self.animation:update()
  end
end

return AnimatedObject