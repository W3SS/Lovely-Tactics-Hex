
--[[===============================================================================================

WaitRule
---------------------------------------------------------------------------------------------------
Rule that just ends the turn. May be used when the other rules cannot be used.

=================================================================================================]]

-- Imports
local ScriptRule = require('core/battle/ai/dynamic/ScriptRule')

local WaitRule = class(ScriptRule)

---------------------------------------------------------------------------------------------------
-- Execution
---------------------------------------------------------------------------------------------------

function WaitRule:execute(user)
  print('wait')
  return 0
end

return WaitRule
