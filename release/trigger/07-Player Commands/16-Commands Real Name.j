function Trig_Commands_Real_Name_Actions takes nothing returns nothing
    local integer playerId
    if Commands_StartsWithCommand() then
        set playerId = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
        if PlayerNumberIsNotNeutral(playerId) then
            call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This player's real name is : " + udg_RealNames[playerId])
        endif
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Real_Name takes nothing returns nothing
    set gg_trg_Commands_Real_Name = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Real_Name, function Trig_Commands_Real_Name_Actions )
endfunction

