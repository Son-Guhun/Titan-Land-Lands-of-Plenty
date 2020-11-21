scope GiveUnit
/*
    Scripts the behaviour of the "Give Unit To" circles in the Titan Palace.
*/

//! runtextmacro optional DefineHooks()

function Trig_System_Titan_GiveUnit_Conditions takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    local player circleOwner = LoPInitPlayerCircles_Globals.regionTable.player[GetHandleId(GetTriggeringRegion())]
    local LoP_PlayerData pId = LoP_PlayerData.get(circleOwner)

    if trigU != HERO_COSMOSIS() and trigU != HERO_CREATOR() then
    
        call SetUnitPosition(trigU, pId.locX, pId.locY)
        call SetUnitOwner(trigU, circleOwner, false)
    endif
    
    set trigU = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Titan_GiveUnit takes nothing returns nothing
    set gg_trg_System_Titan_GiveUnit = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_System_Titan_GiveUnit, Condition( function Trig_System_Titan_GiveUnit_Conditions ) )
endfunction

endscope
