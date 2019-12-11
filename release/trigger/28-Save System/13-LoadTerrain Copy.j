function Trig_LoadTerrainNew_Actions takes nothing returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    local string syncStr = BlzGetTriggerSyncData()
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
        if IsTerrainHeader(syncStr) then
            call LoadTerrainHeader(syncStr, playerId.centerX, playerId.centerY, true)
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

