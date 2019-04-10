function Trig_Commands_SetAlliance_Conditions takes nothing returns boolean
    local integer i
    local integer allianceState
    local string command = LoP_Command.getCommand()
    local string arguments = LoP_Command.getArguments()
    
    if command == "-ally" then
        set allianceState = bj_ALLIANCE_ALLIED_VISION
    elseif command == "-unally" then
        set allianceState = bj_ALLIANCE_UNALLIED
    else
        set allianceState = bj_ALLIANCE_ALLIED_ADVUNITS
    endif
    
    if ( arguments == "all" ) then
        set i = 0
        loop
        exitwhen i >= bj_MAX_PLAYERS
            call SetPlayerAllianceStateBJ( GetTriggerPlayer(), Player(i),  allianceState)
            set i = i + 1
        endloop
    else
        set i = Commands_GetChatMessagePlayerNumber(arguments)
        if PlayerNumberIsNotNeutral(i) then
            call SetPlayerAllianceStateBJ( GetTriggerPlayer(), ConvertedPlayer(i),  allianceState)
        endif
    endif
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Set_Alliance takes nothing returns nothing
    call LoP_Command.create("-ally", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions))
    call LoP_Command.create("-unally", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions))
    call LoP_Command.create("-share", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions))
endfunction

