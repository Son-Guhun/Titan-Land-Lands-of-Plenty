function Trig_LoadTerrainNew_Actions takes nothing returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    local string syncStr = BlzGetTriggerSyncData()
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if stringsLoaded[playerNumber] < loadLimit then
        set stringsLoaded[playerNumber] = stringsLoaded[playerNumber] + 1
        if (saveData.version < 7 and IsTerrainHeader(syncStr)) or IsTerrainHeaderV7(syncStr) then
            if saveData.atOriginal then
                if saveData.version == 3 then
                    call LoadTerrainHeader(syncStr, playerId.centerX, playerId.centerY, true)
                else
                    call LoadTerrainHeader(syncStr, saveData.centerX + playerId.centerX, saveData.centerY + playerId.centerY, false)
                endif
            else
                call LoadTerrainHeader(syncStr, saveData.centerX, saveData.centerY, false)
            endif
        else
            call LoadTerrain(syncStr)
        endif
    endif
endfunction


//===========================================================================
function InitTrig_LoadTerrain_Copy takes nothing returns nothing
    set gg_trg_LoadTerrain_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadTerrain_Copy, function Trig_LoadTerrainNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadTerrain_Copy, "SnL_ter", false)
endfunction

