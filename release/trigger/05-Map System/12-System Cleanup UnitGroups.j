globals
    boolean g_unitHasBeenRemoved = false
endglobals


function Trig_System_Cleanup_UnitGroups_Actions takes nothing returns nothing
    local integer udg_temp_integer
    local integer udg_temp_integer2 = bj_MAX_PLAYERS
    if g_unitHasBeenRemoved then
        set udg_temp_integer = 1
        loop
            exitwhen udg_temp_integer > udg_temp_integer2
            call GroupRefresh(udg_System_NeutralUnits[udg_temp_integer - 1])
            call GroupRefresh(udg_Player_ControlGroup[udg_temp_integer])
            set udg_temp_integer = udg_temp_integer + 1
        endloop
        // call GroupRefresh(udg_GUMS_LoopGroup) // Refreshing GUMS_LoopGroup should be unnecessary, since clearing unit data removes unit from GUMS_LoopGroup
        call GroupRefresh(udg_Abilities_AoRest_UnitGroup)
        set g_unitHasBeenRemoved = false
    else
    endif
endfunction

//===========================================================================
function InitTrig_System_Cleanup_UnitGroups takes nothing returns nothing
    set gg_trg_System_Cleanup_UnitGroups = CreateTrigger(  )
    call TriggerRegisterTimerEventPeriodic( gg_trg_System_Cleanup_UnitGroups, 10.00 )
    call TriggerAddAction( gg_trg_System_Cleanup_UnitGroups, function Trig_System_Cleanup_UnitGroups_Actions )
endfunction

