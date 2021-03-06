
--[[===============================================================================================

Battler
---------------------------------------------------------------------------------------------------
A class the holds character's information for battle formula.

=================================================================================================]]

-- Imports
local AttributeSet = require('core/battle/battler/AttributeSet')
local BattlerAI = require('core/battle/ai/BattlerAI')
local Class = require('core/battle/battler/Class')
local EquipSet = require('core/battle/battler/EquipSet')
local Inventory = require('core/battle/Inventory')
local PopupText = require('core/battle/PopupText')
local SkillAction = require('core/battle/action/SkillAction')
local SkillList = require('core/battle/battler/SkillList')
local StatusList = require('core/battle/battler/StatusList')
local TagMap = require('core/datastruct/TagMap')

-- Alias
local copyArray = util.array.copy
local copyTable = util.table.deepCopy
local newArray = util.array.new
local min = math.min

-- Constants
local elementCount = #Config.elements
local hpKey = Config.battle.attHP
local spKey = Config.battle.attSP
local jumpKey = Config.battle.attJump
local stepKey = Config.battle.attStep

local Battler = class()

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

-- Constructor.
-- @param(troop : Troop)
-- @param(save : table)
function Battler:init(troop, save)
  self.troop = troop
  local id = save and save.battlerID or -1
  if id < 0 then
    local charID = save and save.charID
    local charData = Database.characters[charID]
    id = charData.battlerID
  end
  local data = Database.battlers[id]
  self:initProperties(data, save)
  self:initState(data, save)
  if data.scriptAI then
    self.AI = BattlerAI:fromData(data.scriptAI, self)
  end
end
-- Initializes general battler information.
-- @param(data : table) the battler's data from database
-- @param(save : table) the data from save
function Battler:initProperties(data, save)
  self.key = save.key
  self.charID = save.charID
  self.data = data
  self.name = save and save.name or data.name
  self.x = save and save.x
  self.y = save and save.y
  self.tags = TagMap(data.tags)
end
-- Initializes battle state.
-- @param(data : table) the battler's data from database
-- @param(save : table) the data from save
function Battler:initState(data, save)
  self.class = Class(self, save)
  self.inventory = Inventory(save and save.items or data.items or {})
  self.statusList = StatusList(self, save)
  self.equipSet = EquipSet(self, save)
  self.skillList = SkillList(self, save)
  self.attackSkill = SkillAction:fromData(save.attackID or data.attackID)
  -- Elements
  self.elementBase = save and save.elements and copyArray(save.elements)
  if not self.elementBase then
    local e = newArray(elementCount, 0)
    for i = 1, #data.elements do
      e[data.elements[i].id] = (data.elements[i].value - 100) / 100
    end
    self.elementBase = e
  end
  -- Attributes
  self.att = AttributeSet(self, save)
  self.jumpPoints = self.att[jumpKey]
  self.maxSteps = self.att[stepKey]
  self.mhp = self.att[hpKey]
  self.msp = self.att[spKey]
  -- State variables
  if save and save.state then
    self.state = copyTable(save.state)
  else
    self.state = {}
    self.state.hp = math.huge
    self.state.sp = math.huge
  end
  self:updateState()
end

---------------------------------------------------------------------------------------------------
-- HP and SP damage
---------------------------------------------------------------------------------------------------

-- Limits each state variable to its maximum.
function Battler:updateState()
  self.state.hp = min(self.mhp(), self.state.hp)
  self.state.sp = min(self.msp(), self.state.sp)
end
-- Damages HP.
-- @param(value : number) the number of the damage
-- @ret(boolean) true if reached 0, otherwise
function Battler:damageHP(value)
  value = self.state.hp - value
  if value <= 0 then
    self.state.hp = 0
    return true
  else
    self.state.hp = min(value, self.mhp())
    return false
  end
end
-- Damages SP.
-- @param(value : number) the number of the damage
-- @ret(boolean) true if reached 0, otherwise
function Battler:damageSP(value)
  value = self.state.sp - value
  if value <= 0 then
    self.state.sp = 0
    return true
  else
    self.state.sp = min(value, self.msp())
    return false
  end
end
-- Decreases the points given by the key.
-- @param(key : string) HP, SP or other designer-defined point type
-- @param(value : number) value to be decreased
function Battler:damage(key, value)
  if key == hpKey then
    self:damageHP(value)
  elseif key == spKey then
    self:damageSP(value)
  else
    return false
  end
  return true
end
-- Applies results and creates a popup for each value.
-- @param(pos : Vector) the character's position
-- @param(results : table) the array of effect results
function Battler:popupResults(pos, results, character)
  local popupText = PopupText(pos.x, pos.y - 20, pos.z - 10)
  for i = 1, #results.points do
    local points = results.points[i]
    if points.heal then
      popupText:addHeal(points)
      self:damage(points.key, -points.value)
    else
      popupText:addDamage(points)
      self:damage(points.key, points.value)
    end
  end
  for i = 1, #results.status do
    local r = results.status[i]
    local popupName, text
    if r.add then
      local s = self.statusList:addStatus(r.id, nil, character)
      popupText:addStatus(s)
    else
      local s = self.statusList:removeAllStatus(r.id, character)
      popupText:removeStatus(s)
    end
  end
  popupText:popup()
end
-- Applies the result of a skill.
function Battler:applyResults(results, character)
  for i = 1, #results.points do
    local points = results.points[i]
    if points.heal then
      self:damage(points.key, -points.value)
    else
      self:damage(points.key, points.value)
    end
  end
  if character then
    if self:isAlive() then
      character:playAnimation(character.idleAnim)
    else
      character:playAnimation(character.koAnim, true)
    end
  end
  for i = 1, #results.status do
    local r = results.status[i]
    if r.add then
      self.statusList:addStatus(r.id, nil, character)
    else
      self.statusList:removeAllStatus(r.id, character)
    end
  end
end
-- Applies a list of costs (HP, SP or other state variable).
-- @param(costs : table) array of tables with the variable key and the cost functions
function Battler:damageCosts(costs)
  for i = 1, #costs do
    local value = costs[i].cost(self.att)
    self:damage(costs[i].key, value)
  end
end

---------------------------------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------------------------------

-- Checks if battler is still alive by its HP.
-- @ret(boolean) true if HP greater then zero, false otherwise
function Battler:isAlive()
  return self.state.hp > 0 and not self.statusList:isDead()
end
-- Checks if the character is considered active in the battle.
-- @ret(boolean)
function Battler:isActive()
  return self:isAlive() and not self.statusList:isDeactive()
end
-- Gets an element multiplying factor.
-- @param(id : number) the element's ID (position in the elements database)
function Battler:element(id)
  return self.elementBase[id] + self.statusList:elementBonus(id)
end
-- Gets the battler's AI, if any.
-- @ret(BattlerAI)
function Battler:getAI()
  return self.statusList:getAI() or self.AI
end

---------------------------------------------------------------------------------------------------
-- Battle Callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the battle ends.
function Battler:onBattleStart(char)
  if self.AI and self.AI.onBattleStart then
    self.AI:onBattleStart(self, char)
  end
  self.equipSet:addBattleStatus(char)
  self.statusList:callback('BattleStart', char)
end
-- Callback for when the battle ends.
function Battler:onBattleEnd(char)
  if self.AI and self.AI.onBattleEnd then
    self.AI:BattleEnd(self, char)
  end
  self.statusList:callback('BattleEnd', char)
end

---------------------------------------------------------------------------------------------------
-- Skill callbacks
---------------------------------------------------------------------------------------------------

-- Callback for when the character finished using a skill.
function Battler:onSkillUse(input, character)
  self.statusList:callback('SkillUse', input, character)
end
-- Callback for when the characters ends receiving a skill's effect.
function Battler:onSkillEffect(input, results, character)
  self.statusList:callback('SkillEffect', input, results, character)
end

---------------------------------------------------------------------------------------------------
-- Save
---------------------------------------------------------------------------------------------------

-- Creates a table that stores the battler's current state to be saved.
-- @ret(table)
function Battler:createPersistentData()
  return {
    key = self.key,
    x = self.x,
    y = self.y,
    name = self.name,
    charID = self.charID,
    battlerID = self.data.id,
    state = copyTable(self.state),
    elements = copyTable(self.elementBase),
    att = self.att:getState(),
    class = self.class:getState(),
    equips = self.equipSet:getState(),
    status = self.statusList:getState(),
    skills = self.skillList:getState() }
end

return Battler
