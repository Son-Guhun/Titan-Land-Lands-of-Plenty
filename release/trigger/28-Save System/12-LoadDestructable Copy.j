function Trig_LoadDestNew_Actions takes nothing returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
        if saveData.atOriginal then
            call LoadDestructable(BlzGetTriggerSyncData(), saveData.centerX + playerId.centerX, saveData.centerY+playerId.centerY)
        else
            call LoadDestructable(BlzGetTriggerSyncData(), saveData.centerX, saveData.centerY)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_LoadDestructable_Copy takes nothing returns nothing
    set gg_trg_LoadDestructable_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadDestructable_Copy, function Trig_LoadDestNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadDestructable_Copy, "SnL_dest", false)
endfunction
