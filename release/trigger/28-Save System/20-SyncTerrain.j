function Trig_LoadTerrainNew_Actions takes nothing returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    local string syncStr = BlzGetTriggerSyncData()
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if syncStr == "end" then
        call LoadTerrainFinish(playerId)
    elseif stringsLoaded[playerNumber] < loadLimit then
        set stringsLoaded[playerNumber] = stringsLoaded[playerNumber] + 1
        if (saveData.version < 7 and IsTerrainHeader(syncStr)) or IsTerrainHeaderV7(syncStr) then
            if saveData.atOriginal then
                if saveData.version == 3 then
                    call LoadTerrainHeader(playerId, syncStr, playerId.centerX, playerId.centerY, true)
                else
                    call LoadTerrainHeader(playerId, syncStr, saveData.centerX + playerId.centerX, saveData.centerY + playerId.centerY, false)
                endif
            else
                call LoadTerrainHeader(playerId, syncStr, saveData.centerX, saveData.centerY, false)
            endif
        else
            call LoadTerrain(playerId, syncStr)
        endif
    endif
endfunction


//===========================================================================
function InitTrig_SyncTerrain takes nothing returns nothing
    set gg_trg_SyncTerrain = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SyncTerrain, function Trig_LoadTerrainNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_SyncTerrain, "SnL_ter", false)
endfunction

