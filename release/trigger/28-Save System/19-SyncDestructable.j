function Trig_LoadDestNew_Actions takes nothing returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if stringsLoaded[playerNumber] < loadLimit then
        set stringsLoaded[playerNumber] = stringsLoaded[playerNumber] + 1
        if saveData.atOriginal then
            call LoadDestructable(BlzGetTriggerSyncData(), saveData.centerX + playerId.centerX, saveData.centerY+playerId.centerY)
        else
            call LoadDestructable(BlzGetTriggerSyncData(), saveData.centerX, saveData.centerY)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_SyncDestructable takes nothing returns nothing
    set gg_trg_SyncDestructable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SyncDestructable, function Trig_LoadDestNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_SyncDestructable, "SnL_dest", false)
endfunction

