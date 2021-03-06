
--[[===============================================================================================

PopupText
---------------------------------------------------------------------------------------------------
A text sprite that is shown in the field with a popup animation.

=================================================================================================]]

-- Imports
local Text = require('core/graphics/Text')

-- Alias
local time = love.timer.getDelta
local max = math.max

-- Constants
local distance = 15
local speed = 8
local pause = 30
local properties = {nil, 'left'}

local PopupText = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor. Starts with no lines.
-- @param(x : number) origin pixel x
-- @param(y : number) origin pixel y
-- @param(z : number) origin pixel z (depth)
function PopupText:init(x, y, z, renderer)
  self.x = x
  self.y = y
  self.z = z
  self.text = nil
  self.lineCount = 0
  self.resources = {}
  self.renderer = renderer or FieldManager.renderer
end

---------------------------------------------------------------------------------------------------
-- Lines
---------------------------------------------------------------------------------------------------

-- Adds a new line.
-- @param(text : string) the text content
-- @param(color : table) the text color (red/green/blue/alpha table)
-- @param(font : Font) the text font
function PopupText:addLine(text, color, font)
  text = '{c' .. color .. '}{f' .. font .. '}' .. text
  local l = self.lineCount
  if l > 0 then
    text = self.text .. '\n' .. text
  end
  self.lineCount = l + 1
  self.text = text
end
-- Add a line to show damage.
-- @param(points : table) result data from skill
function PopupText:addDamage(points)  
  local popupName = 'popup_dmg' .. points.key
  self:addLine(points.value, popupName, popupName)
end
-- Add a line to show heal.
-- @param(points : table) result data from skill
function PopupText:addHeal(points)
  local popupName = 'popup_heal' .. points.key
  self:addLine(points.value, popupName, popupName)
end

function PopupText:addStatus(s)
  local popupName = 'popup_status_add' .. s.data.id
  local color = Color[popupName] and popupName or 'popup_status_add'
  local font = Fonts[popupName] and popupName or 'popup_status_add'
  self:addLine('+' .. s.data.name, color, font)
end

function PopupText:removeStatus(all)
  for i = 1, #all do
    local s = all[i]
    local popupName = 'popup_status_remove' .. s.data.id
    local color = Color[popupName] and popupName or 'popup_status_remove'
    local font = Fonts[popupName] and popupName or 'popup_status_remove'
    self:addLine('-' .. s.data.name, color, font)
  end
end

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

-- [COROUTINE] Show the text lines in a pop-up.
-- @param(wait : boolean) true if the coroutine shoul wait until the animation finishes (optional)
function PopupText:popup(wait)
  if not self.text then
    return
  end
  if not wait then
    _G.Fiber:fork(function()
      self:popup(true)
    end)
  else
    local sprite = Text(self.text, properties, self.renderer)
    sprite:setXYZ(self.x, self.y, self.z)
    sprite:setCenterOffset()
    local d = 0
    while d < distance do
      d = d + distance * speed * time()
      sprite:setXYZ(nil, self.y - d)
      coroutine.yield()
    end
    _G.Fiber:wait(pause)
    local f = 100 / (sprite.color.alpha / 255)
    while sprite.color.alpha > 0 do
      local a = max(sprite.color.alpha - speed * time() * f, 0)
      sprite:setRGBA(nil, nil, nil, a)
      coroutine.yield()
    end
    sprite:removeSelf()
  end
end
-- Destroys this popup's sprite.
function PopupText:destroy()
  self.sprite:destroy()
end

return PopupText
