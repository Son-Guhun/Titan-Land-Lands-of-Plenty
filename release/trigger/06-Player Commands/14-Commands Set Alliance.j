function Trig_Commands_Share_Actions takes nothing returns nothing
    local integer i
    local integer allianceState
    
    if not Commands_StartsWithCommand() then
        return
    endif
    
    if GetEventPlayerChatStringMatched() == "-ally " then
        set allianceState = bj_ALLIANCE_ALLIED_VISION
    elseif GetEventPlayerChatStringMatched() == "-unally " then
        set allianceState = bj_ALLIANCE_UNALLIED
    else
        set allianceState = bj_ALLIANCE_ALLIED_ADVUNITS
    endif
    
    if ( Commands_GetArguments() == "all" ) then
        set i = 0
        loop
        exitwhen i >= bj_MAX_PLAYERS
            call SetPlayerAllianceStateBJ( GetTriggerPlayer(), Player(i),  allianceState)
            set i = i + 1
        endloop
    else
        set i = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
        if PlayerNumberIsNotNeutral(i) then
            call SetPlayerAllianceStateBJ( GetTriggerPlayer(), ConvertedPlayer(i),  allianceState)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Set_Alliance takes nothing returns nothing
    set gg_trg_Commands_Set_Alliance = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Set_Alliance, function Trig_Commands_Share_Actions )
endfunction

