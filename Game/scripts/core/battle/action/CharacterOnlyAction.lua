
--[[===========================================================================

A special type of Skill that only selects tiles with characters on it.

=============================================================================]]

-- Imports
local PriorityQueue = require('core/algorithm/PriorityQueue')
local MoveAction = require('core/battle/action/MoveAction')
local SkillAction = require('core/battle/action/SkillAction')
local PathFinder = require('core/algorithm/PathFinder')

local CharacterOnlyAction = SkillAction:inherit()

-------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------

-- Overrides BattleAction:onSelect.
local old_onSelect = CharacterOnlyAction.onSelect
function CharacterOnlyAction:onSelect()
  self.index = 1
  self.selectableTiles = self:getSelectableTiles()
end

-- Gets the list of all tiles that have a character.
-- @ret(List) the list of ObjectTiles
function CharacterOnlyAction:getSelectableTiles()
  local moveAction = MoveAction(self.currentTarget, self.user, self.data.range)
  local tempQueue = PriorityQueue()
  for char in TroopManager.characterList:iterator() do
    if self:isCharacterSelectable(char) then
      local tile = char:getTile()
      moveAction.currentTarget = tile
      local path = PathFinder.findPath(moveAction, nil, true)
      if path == nil then
        tempQueue:enqueue(tile, math.huge)
      else
        tempQueue:enqueue(tile, path.totalCost)
      end
    end
  end
  return tempQueue:toList()
end

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------

-- Overrides BattleAction:onActionGUI.
function CharacterOnlyAction:onActionGUI(GUI)
  self:resetAllTiles(false)
  self:resetTargetTiles(false, false)
  self:resetCharacterTiles()
  GUI:startGridSelecting(self:firstTarget())
end

-------------------------------------------------------------------------------
-- Selectable Tiles
-------------------------------------------------------------------------------

-- Overrides BattleAction:isSelectable.
function CharacterOnlyAction:isSelectable(tile)
  for char in tile.characterList:iterator() do
    if self:isCharacterSelectable(char) then
      return true
    end
  end
  return false
end

-- Tells if the given character is selectable.
-- @param(char : Character) the character to check
-- @ret(boolean) true if selectable, false otherwise
function CharacterOnlyAction:isCharacterSelectable(char)
  return true
end

-- Sets all character tiles as selectable.
function CharacterOnlyAction:resetCharacterTiles()
  for i = 1, self.selectableTiles.size do
    local t = self.selectableTiles[i]
    t.selectable = true
    t:setColor(t.colorName)
  end
end

-------------------------------------------------------------------------------
-- Grid selecting
-------------------------------------------------------------------------------

-- Overrides BattleAction:firstTarget.
function CharacterOnlyAction:firstTarget()
  return self.selectableTiles[1]
end

-- Overrides BattleAction:nextTarget.
function CharacterOnlyAction:nextTarget(dx, dy)
  if dx > 0 or dy > 0 then
    if self.index == self.selectableTiles.size then
      self.index = 1
    else
      self.index = self.index + 1
    end
  else
    if self.index == 1 then
      self.index = self.selectableTiles.size
    else
      self.index = self.index - 1
    end
  end
  return self.selectableTiles[self.index]
end

return CharacterOnlyAction
