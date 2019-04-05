//Checks the deco counter for the player. If any counter is 0, create the missing deco.
function Commands_CreateMissingDecos takes player whichPlayer returns nothing
    local integer playerNumber = GetPlayerId( whichPlayer ) + 1
    local integer i = 0
    loop
    exitwhen i > udg_System_DecoTotal
        if LoadInteger(udg_Hashtable_2, playerNumber, udg_DecoUnitTypes[i] ) == 0 then
            call CreateUnitAtLoc( whichPlayer, udg_DecoUnitTypes[i], udg_PLAYER_LOCATIONS[playerNumber], bj_UNIT_FACING )
        endif
        set i = i + 1
    endloop
endfunction

function Trig_Commands_Deco_Spawn_Actions takes nothing returns nothing
    call Commands_CreateMissingDecos(GetTriggerPlayer())
endfunction

//===========================================================================
function InitTrig_Commands_Deco_Spawn takes nothing returns nothing
    set gg_trg_Commands_Deco_Spawn = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Deco_Spawn, function Trig_Commands_Deco_Spawn_Actions )
endfunction

