
--[[===============================================================================================

Player
---------------------------------------------------------------------------------------------------
This is a special character that can me controlled by the player with keyboard.
It only exists for exploration fields.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local Character = require('core/objects/Character')

-- Alias
local timer = love.timer
local coord2Angle = math.coord2Angle
local tile2Pixel = math.field.tile2pixel

-- Constants
local conf = Config.player
local tg = math.field.tg

local Player = class(Character)

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- Overrides BaseCharacter:init.
local old_init = Player.init
function Player:init(initTile)
  self.blocks = 0
  self.dashSpeed = conf.dashSpeed
  self.walkSpeed = conf.walkSpeed
  local leaderBattler = Database.battlers[PartyManager.members[1] + 1]
  local data = {
    animID = 0,
    direction = 270,
    startScript = conf.script,
    id = leaderBattler.fieldCharID,
    tags = {}
  }
  old_init(self, '0', data, initTile)
end

-- Player's extra and base character properties.
local old_initializeProperties = Player.initializeProperties
function Player:initializeProperties(name, colliderSize, colliderHeight)
  old_initializeProperties(self, 'Player', colliderSize, colliderHeight)
  self.inputOn = true
  self.speed = conf.walkSpeed
  self.interruptableMove = conf.stopOnCollision
end

---------------------------------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------------------------------

-- Checks if field input is enabled.
-- @ret(boolean) true if enabled, false otherwise
function Player:fieldInputEnabled()
  if GUIManager:isWaitingInput() then
    return false
  end
  return self.inputOn and self.moveTime >= 1 and self.blocks == 0
end

-- [COROUTINE] Moves player depending on input.
-- @param(dx : number) input x
-- @param(dy : number) input y
function Player:moveByInput(dx, dy)
  if dx ~= 0 or dy ~= 0 then
    local moved = false
    local autoAnim = self.autoAnim
    self.autoAnim = false
    if autoAnim then
      if self.speed < conf.dashSpeed then
        self:playAnimation(self.walkAnim)
      else
        self:playAnimation(self.dashAnim)
      end
    end
    if conf.pixelMovement == true then
      moved = self:pixelMovement(dx, dy)
    else
      moved = self:tileMovement(dx, dy)
    end
    if not moved then
      if self.autoTurn then
        self:setDirection(math.coord2Angle(dx, dy))
      end
      if autoAnim then
        self:playAnimation(self.idleAnim)
      end
      if conf.pixelMovement == false then
        self:adjustToTile()
      end
    end
    self.autoAnim = autoAnim
  else
    if self.autoAnim then
      self:playAnimation(self.idleAnim)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Tile Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player with keyboard input (a complete tile).
-- @param(dx : number) input x
-- @param(dy : number) input y
-- @ret(boolean) true if player actually moved, false otherwise
function Player:tileMovement(dx, dy)
  local angle = coord2Angle(dx, dy)
  return self:tryMoveTile(angle) or self:tryMoveTile(angle + 45) or self:tryMoveTile(angle - 45)
end

-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) the angle in degrees to move
-- @ret(boolean) returns false if the next angle must be tried
function Player:tryMoveTile(angle)
  local nextTile = self:frontTile(angle)
  if nextTile == nil then
    return false
  end
  local ox, oy, oh = self:getTile():coordinates()
  local dx, dy, dh = nextTile:coordinates()
  local collision = FieldManager.currentField:collisionXYZ(self,
    ox, oy, oh, dx, dy, dh)
  if collision ~= nil then
    if collision ~= 3 then -- not a character
      return false
    else
      self:playAnimation(self.idleAnim)
      self:turnToTile(dx, dy) -- character
      return true
    end
  else
    self:walkToTile(dx, dy, dh, false)
    return true
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Pixel Movement
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Moves player with keyboard input.
-- @param(dx : number) input x
-- @param(dy : number) input y
-- @ret(boolean) true if player actually moved, false otherwise
function Player:pixelMovement(dx, dy)
  local angle = math.coord2Angle(dx, dy)
  return self:tryMovePixel(angle) or self:tryMovePixel(angle + 45) or self:tryMovePixel(angle - 45)
end

-- [COROUTINE] Tries to move in a given angle.
-- @param(angle : number) the angle in degrees to move
-- @ret(boolean) returns false if the next angle must be tried
function Player:tryMovePixel(angle)
  local dx, dy = math.angle2Coord(angle)
  dy = dy * tg
  local v = Vector(dx, -dy, 0)
  v:normalize()
  v.z = - v.y
  v:mul(self.speed * timer.getDelta())
  self:turnToVector(v.x, v.z)
  local p = self.position
  local collision = self:instantMoveTo(p.x + v.x, p.y + v.y, p.z + v.z)
  if collision == nil then
    self:playAnimation(self.walkAnimation)
    return true
  else
    return collision == 3
  end
end

return Player