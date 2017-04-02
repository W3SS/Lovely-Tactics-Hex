
--[[===========================================================================

AnimatedObject
-------------------------------------------------------------------------------
An object with a table of animations.

=============================================================================]]

-- Imports
local Sprite = require('core/graphics/Sprite')
local Animation = require('core/graphics/Animation')
local Object = require('core/fields/Object')

-- Alias
local mathf = math.field
local Quad = love.graphics.newQuad

local AnimatedObject = Object:inherit()

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Creates sprite and animation list.
-- @param(animations : table) an array of animation data
-- @param(animID : number) the start animation's ID
function AnimatedObject:initializeGraphics(animations, animID, transform)
  self.transform = transform
  self.animationData = {}
  self.sprite = Sprite(FieldManager.renderer)
  for i = #animations, 1, -1 do
    self:addAnimation(animations[i].name, animations[i].id)
  end
  local first = animations[animID + 1].name
  local data = self.animationData[first]
  self:playAnimation(first)
end

-- Creates a new animation from the database.
-- @param(name : string) the name of the animation for the character
-- @param(id : number) the animation's ID in the database
function AnimatedObject:addAnimation(name, id)
  local data = Database.animCharacter[id + 1]
  local animation, texture, quad = Animation.fromData(data, FieldManager.renderer, self.sprite)
  self.animationData[name] = {
    transform = data.transform,
    animation = animation,
    texture = texture,
    quad = quad
  }
end

-------------------------------------------------------------------------------
-- Play
-------------------------------------------------------------------------------

-- [COROUTINE] Plays an animation by name.
-- @param(name : string) animation's name
-- @param(wait : boolean) true to wait until first loop finishes (optional)
function AnimatedObject:playAnimation(name, wait, row)
  local data = self.animationData[name]
  assert(data, "Animation does not exist: " .. name)
  if self.animation == data.animation then
    return self.animation
  end
  local anim = data.animation
  self.sprite:setTexture(data.texture)
  self.sprite.quad = data.quad
  self.sprite:setTransformation(self.transform)
  self.sprite:applyTransformation(data.transform)
  self.animation = anim
  anim.sprite = self.sprite
  if row then
    anim:setRow(row)
  end
  anim.paused = false
  if wait then
    _G.Callback:wait(anim.duration)
  end
  return anim
end

-------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------

-- Updates animation.
local old_update = AnimatedObject.update
function AnimatedObject:update()
  old_update(self)
  if self.animation then
    self.animation:update()
  end
end

-- Removes from draw and update list.
function AnimatedObject:destroy()
  if self.sprite then
    self.sprite:removeSelf()
  end
end

return AnimatedObject
