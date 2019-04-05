function Trig_LoadTerrain_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    if Save_IsPlayerLoading(playerId) then
        if udg_load_number[playerNumber] < udg_load_limit then
            set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
            call LoadTerrain(GetEventPlayerChatString())
        endif
    endif
endfunction


//===========================================================================
function InitTrig_LoadTerrain takes nothing returns nothing
    set gg_trg_LoadTerrain = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadTerrain, function Trig_LoadTerrain_Actions )
endfunction

