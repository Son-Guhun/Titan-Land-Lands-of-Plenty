function Trig_LoadUnitNew_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())+1
    
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
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadUnit_Copy, "SnL_unit", false)
endfunction

