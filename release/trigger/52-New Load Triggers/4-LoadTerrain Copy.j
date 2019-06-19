function Trig_LoadTerrainNew_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
        call LoadTerrain(BlzGetTriggerSyncData())
    endif
endfunction


//===========================================================================
function InitTrig_LoadTerrain_Copy takes nothing returns nothing
    set gg_trg_LoadTerrain_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadTerrain_Copy, function Trig_LoadTerrainNew_Actions )
    call BlzTriggerRegisterPlayerSyncEvent( gg_trg_LoadTerrain_Copy, Player(0), "SnL_ter", false)
endfunction

