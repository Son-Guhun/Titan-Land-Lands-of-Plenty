function Trig_LoadUnitNew_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId+1
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = ( udg_load_number[playerNumber] + 1 )
        call LoadUnit(BlzGetTriggerSyncData()/*GetEventPlayerChatString()*/,GetTriggerPlayer())
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit_Copy takes nothing returns nothing
    set gg_trg_LoadUnit_Copy = CreateTrigger(  )
    //call DisableTrigger( gg_trg_LoadUnit_Copy )
    call TriggerAddAction( gg_trg_LoadUnit_Copy, function Trig_LoadUnitNew_Actions )
    call BlzTriggerRegisterPlayerSyncEvent( gg_trg_LoadUnit_Copy, Player(0), "SnL_unit", false)
endfunction

