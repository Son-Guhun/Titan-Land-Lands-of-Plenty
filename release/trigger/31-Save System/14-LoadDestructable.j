function Trig_LoadDest_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId + 1
    if Save_IsPlayerLoading(playerId) then
        if udg_load_number[playerNumber] < udg_load_limit then
            set udg_load_number[playerNumber] = udg_load_number[playerNumber] + 1
            call LoadDestructable(GetEventPlayerChatString())
        endif
    endif
endfunction

//===========================================================================
function InitTrig_LoadDestructable takes nothing returns nothing
    set gg_trg_LoadDestructable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadDestructable, function Trig_LoadDest_Actions )
endfunction

