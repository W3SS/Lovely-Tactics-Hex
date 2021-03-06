
--[[===============================================================================================

KillCheat
---------------------------------------------------------------------------------------------------
Adds a key to kill all enemies in the nuxt turn during battle.
Used to skip battles during game test.

=================================================================================================]]

KeyMap[args.key] = 'kill'

-- Imports
local TurnManager = require('core/battle/TurnManager')

local function killAll(party)
  for char in TroopManager.characterList:iterator() do
    if char.party ~= party then
      char.battler.state.hp = 0
    end
  end
end

local TurnManager_runTurn = TurnManager.runTurn
function TurnManager:runTurn()
  if InputManager.keys['kill']:isPressing() then
    killAll(TroopManager.playerParty)
    return 1, TroopManager.playerParty
  else
   return TurnManager_runTurn(self)
  end
end
