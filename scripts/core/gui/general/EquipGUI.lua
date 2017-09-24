
--[[===============================================================================================

EquipGUI
---------------------------------------------------------------------------------------------------
The GUI that contains only a confirm window.

=================================================================================================]]

-- Imports
local Vector = require('core/math/Vector')
local GUI = require('core/gui/GUI')
local EquipWindow = require('core/gui/general/window/EquipWindow')
local EquipListWindow = require('core/gui/general/window/EquipListWindow')
local DescriptionWindow = require('core/gui/general/window/DescriptionWindow')

local EquipGUI = class(GUI)

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function EquipGUI:createWindows()
  self.name = 'Equip GUI'
  self:createListWindow()
  self:createMainWindow()
  self:createDescriptionWindow()
end

function EquipGUI:createListWindow()
  local window = EquipListWindow(self, TurnManager:currentTroop())
  self.listWindow = window
  self.windowList:add(window)
  self:setActiveWindow(window)
end

function EquipGUI:createMainWindow()
  local member = self.listWindow.buttonMatrix[1].member
  local w = ScreenManager.width - self.listWindow.width * 2 - self:windowMargin() * 3
  local h = self.listWindow.height
  local x = self.listWindow.width * 2 + self:windowMargin() - ScreenManager.width / 2
  local y = self:windowMargin() - ScreenManager.height / 2 + h / 2
  local window = EquipWindow(self, w, h, Vector(x, y), self.listWindow.fitRowCount, member)
  window:setSelectedButton(nil)
  self.mainWindow = window
  self.windowList:add(window)
end

function EquipGUI:createDescriptionWindow()
  local w = ScreenManager.width - self:windowMargin() * 2
  local h = ScreenManager.height - self.listWindow.height - self:windowMargin() * 3
  local pos = Vector(0, ScreenManager.height / 2 - h / 2 - self:windowMargin())
  local window = DescriptionWindow(self, w, h, pos)
  self.descriptionWindow = window
  self.windowList:add(window)
end

return EquipGUI