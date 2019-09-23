scope GiveUnit

function Trig_System_Titan_GiveUnit_Conditions takes nothing returns boolean
    if ( not ( GetTriggerUnit() != HERO_COSMOSIS() ) ) then
        return false
    endif
    if ( not ( GetTriggerUnit() != HERO_CREATOR() ) ) then
        return false
    endif
    return true
endfunction

function Trig_System_Titan_GiveUnit_Actions takes nothing returns nothing
    local player udg_temp_player = LoPInitPlayerCircles_Globals.regionTable.player[GetHandleId(GetTriggeringRegion())]
    local location loc = udg_PLAYER_LOCATIONS[GetPlayerId(udg_temp_player) + 1]
    call SetUnitPosition( GetTriggerUnit(), GetLocationX(loc), GetLocationY(loc))
    call SetUnitOwner( GetTriggerUnit(), udg_temp_player, true )
    set loc = null
endfunction

//===========================================================================
function InitTrig_System_Titan_GiveUnit takes nothing returns nothing
    set gg_trg_System_Titan_GiveUnit = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_System_Titan_GiveUnit, Condition( function Trig_System_Titan_GiveUnit_Conditions ) )
    call TriggerAddAction( gg_trg_System_Titan_GiveUnit, function Trig_System_Titan_GiveUnit_Actions )
endfunction

endscope
