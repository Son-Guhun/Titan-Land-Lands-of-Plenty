/*
    Change player name upon unit selection.
*/

function Trig_System_Autoname_Actions takes nothing returns boolean
    local player trigPlayer = GetTriggerPlayer()
    local unit trigUnit = GetTriggerUnit()

    if UnitVisuals[trigUnit].hasCustomName() and GetOwningPlayer(trigUnit) == trigPlayer and udg_System_AutonameBoolean[GetPlayerId(trigPlayer) + 1] then
        call SetPlayerName(trigPlayer, UnitVisuals.getUnitName(trigUnit))
    endif

    set trigUnit = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Autoname takes nothing returns nothing
    set gg_trg_System_Autoname = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_System_Autoname, Condition(function Trig_System_Autoname_Actions ))
endfunction

