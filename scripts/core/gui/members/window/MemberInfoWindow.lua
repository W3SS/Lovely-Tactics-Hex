
--[[===============================================================================================

MemberInfoWindow
---------------------------------------------------------------------------------------------------
A window that shows HP and MP of a troop member.

=================================================================================================]]

-- Imports
local MemberInfo = require('core/gui/general/widget/MemberInfo')
local Vector = require('core/math/Vector')
local Window = require('core/gui/Window')

local MemberInfoWindow = class(Window)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function MemberInfoWindow:init(member, ...)
  self.member = member
  Window.init(self, ...)
end

function MemberInfoWindow:createContent(...)
  Window.createContent(self, ...)
  self:setMember(self.member)
end

---------------------------------------------------------------------------------------------------
-- Member
---------------------------------------------------------------------------------------------------

function MemberInfoWindow:setMember(member)
  self.member = member
  if self.info then
    self.info:destroy()
    self.content:removeElement(self.info)
  end
  local w = self.width - self:hPadding() * 2
  local h = self.height - self:vPadding() * 2
  self.info = MemberInfo(self.member, w, h, Vector(-w / 2, -h / 2))
  self.info:updatePosition(self.position)
  self.content:add(self.info)
  if not self.open then
    self.info:hide()
  end
end

---------------------------------------------------------------------------------------------------
-- Properties
---------------------------------------------------------------------------------------------------

function MemberInfoWindow:__tostring()
  return 'Member Info Window'
end

return MemberInfoWindow