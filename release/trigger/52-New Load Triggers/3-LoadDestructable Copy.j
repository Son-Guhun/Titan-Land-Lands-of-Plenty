function Trig_LoadDestNew_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
        call LoadDestructable(BlzGetTriggerSyncData())
    endif
endfunction

//===========================================================================
function InitTrig_LoadDestructable_Copy takes nothing returns nothing
    set gg_trg_LoadDestructable_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadDestructable_Copy, function Trig_LoadDestNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadDestructable_Copy, "SnL_dest", false)
endfunction

