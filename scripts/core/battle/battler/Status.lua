
--[[===============================================================================================

Status
---------------------------------------------------------------------------------------------------
A generic status effect that a battler may have.
The effects of them on battle and field depend on each individual implementation.

=================================================================================================]]

-- Imports
local TagMap = require('core/datastruct/TagMap')

local Status = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(list : StatusList) the list that included this status
-- @param(data : table) status' data from database file
-- @param(state : table) the persistent state of the status
function Status:init(list, data, state)
  -- General
  self.data = data
  self.statusList = list
  self.lifeTime = state and state.lifeTime or 0
  if self.data.duration >= 0 then
    self.duration = self.data.duration
  else
    self.duration = math.huge
  end
  self.tags = TagMap(self.data.tags)
  -- Bonus
  self.attAdd = {}
  self.attMul = {}
  self.elements = {}
  -- Attribute bonus
  for i = 1, #data.attributes do
    local bonus = data.attributes[i]
    self.attAdd[bonus.key] = (bonus.add or 0) / 100
    self.attMul[bonus.key] = (bonus.mul or 0) / 100
  end
  -- Element bonus
  for i = 1, #data.elements do
    local bonus = data.elements[i]
    self.elements[bonus.id] = (bonus.value or 0) / 100
  end
  -- AI
  local ai = data.scriptAI
  if ai and ai.path ~= '' then
    self.AI = require('custom/ai/battler/' .. ai.path)(self, ai.param)
  end
end
-- Creates the status from its ID in the database, loading the correct script.
-- @param(data : table) status' data from database file
-- @param(...) default contructor parameters
function Status:fromData(list, data, ...)
  if data.script.path ~= '' then
    local class = require('custom/' .. data.script.path)
    return class(list, data, ...)
  else
    return self(list, data, ...)
  end
end

---------------------------------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------------------------------

-- String representation.
function Status:__tostring()
  return 'Status: ' .. self.data.id .. ' (' .. self.data.name .. ')'
end
-- @ret(table) status' persistent data. Must include its ID.
function Status:getState()
  return { id = self.data.id,
    lifeTime = self.lifeTime }
end

---------------------------------------------------------------------------------------------------
-- Battle callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's battle-only.
function Status:onBattleEnd()
  if self.data.battleOnly then
    self.statusList:removeStatus(self)
  end
end

---------------------------------------------------------------------------------------------------
-- Turn callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case its lifetime is over.
-- @param(character : Character)
-- @param(partyTurn : boolean)
function Status:onTurnStart(character, partyTurn)
  self.lifeTime = self.lifeTime + 1
  if self.lifeTime > self.duration then
    self.statusList:removeStatus(self, character)
  end
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Removes status in case it's removable by damage or KO.
-- @param(input : ActionInput)
-- @param(results : table)
function Status:onSkillEffect(input, results, char)
  local battler = self.statusList.battler
  if results.damage and self.data.removeOnDamage or 
      self.data.removeOnKO and not battler:isAlive() then
    self.statusList:removeStatus(self, char)
  end
end

return Status