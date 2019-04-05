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
function InitTrig_LoadDest takes nothing returns nothing
    set gg_trg_LoadDest = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadDest, function Trig_LoadDest_Actions )
endfunction

