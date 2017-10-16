
--[[===============================================================================================

CallAction
---------------------------------------------------------------------------------------------------
The BattleAction that is executed when players chooses the "Call Ally" button.

=================================================================================================]]

-- Imports
local CallAction = require('core/battle/action/CallAction')
local CallGUI = require('core/gui/battle/CallGUI')

local PartyAction = class(CallAction)

---------------------------------------------------------------------------------------------------
-- Input callback
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:onConfirm.
function PartyAction:onConfirm(input)
  local troop = TroopManager.troops[(input.party or TurnManager.party)]
  local result = GUIManager:showGUIForResult(CallGUI(troop, input.user == nil))
  if result ~= 0 then
    local char = input.target.characterList[1]
    if result == '' then
      if char then
        troop:removeMember(char)
      else
        return nil
      end
    else
      if char and char.key ~= result then
        troop:removeMember(char)
      end
      local newChar = FieldManager:search(result)
      if newChar then
        newChar:moveToTile(input.target)
      else
        troop:callMember(result, input.target)
      end
    end
    self:resetTileProperties(input)
    self:resetTileColors(input)
    input.GUI:selectTarget(input.target)
  end
end

---------------------------------------------------------------------------------------------------
-- Selectable Tiles
---------------------------------------------------------------------------------------------------

-- Overrides BattleAction:isSelectable.
function PartyAction:isSelectable(input, tile)
  return tile.party == TurnManager.party
end

---------------------------------------------------------------------------------------------------
-- Target
---------------------------------------------------------------------------------------------------

function PartyAction:firstTarget(input)
  local member = TurnManager:currentTroop().current[1]
  local char = FieldManager:search(member.key)
  return char:getTile()
end

return PartyAction
