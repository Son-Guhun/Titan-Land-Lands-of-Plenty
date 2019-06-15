function Trig_LoadRequest_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer i
    local string chatStr = GetEventPlayerChatString()
    if chatStr == "-load ini" then
        call Save_SetPlayerLoading(playerId, true)
        set udg_load_number[playerId + 1] = 0
        call EnableTrigger( gg_trg_LoadUnit )
        call EnableTrigger( gg_trg_LoadUnit_Extra )
        
    elseif chatStr == "-load end" then
        call Save_SetPlayerLoading(playerId, false)
        set i = 0
        loop
        exitwhen Save_IsPlayerLoading(i) or i == bj_MAX_PLAYERS
            set i = i + 1
        endloop
        if i == bj_MAX_PLAYERS then
            call DisableTrigger( gg_trg_LoadUnit )
            call DisableTrigger( gg_trg_LoadUnit_Extra )
        endif
        
    else
        set chatStr = SubString(chatStr,9,129)
        call LoadRequest(GetTriggerPlayer(), chatStr)
    endif
endfunction

//===========================================================================
function InitTrig_LoadRequest takes nothing returns nothing
    set gg_trg_LoadRequest = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadRequest, function Trig_LoadRequest_Actions )
endfunction

