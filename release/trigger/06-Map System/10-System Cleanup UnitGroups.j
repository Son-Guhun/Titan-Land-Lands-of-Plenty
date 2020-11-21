globals
    boolean g_unitHasBeenRemoved = false
endglobals

function Trig_System_Cleanup_UnitGroups_Actions takes nothing returns nothing
    local integer playerNumber

    if g_unitHasBeenRemoved then
        set playerNumber = 1
        loop
        exitwhen playerNumber > bj_MAX_PLAYERS
            if IsPlayerInForce(Player(playerNumber -1), bj_FORCE_ALL_PLAYERS) then
                call LoP_RefreshNeutralUnits(Player(playerNumber - 1))
                call GroupRefresh(udg_Player_ControlGroup[playerNumber])
            endif
            set playerNumber = playerNumber + 1
        endloop
        
        call GroupRefresh(udg_Abilities_AoRest_UnitGroup)
        set g_unitHasBeenRemoved = false
    endif
endfunction

//===========================================================================
function InitTrig_System_Cleanup_UnitGroups takes nothing returns nothing
    call TimerStart(CreateTimer(), 10., true, function Trig_System_Cleanup_UnitGroups_Actions)
endfunction

