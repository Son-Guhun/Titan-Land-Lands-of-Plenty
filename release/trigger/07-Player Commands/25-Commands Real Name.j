function Trig_Commands_Real_Name_Actions takes nothing returns boolean
    local integer playerNumber = Arguments_ParsePlayer(LoP_Command.getArguments())
    
    if PlayerNumberIsNotNeutral(playerNumber) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "This player's real name is : " + udg_RealNames[playerNumber])
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Real_Name takes nothing returns nothing
    call LoP_Command.create("-real", ACCESS_USER, Condition(function Trig_Commands_Real_Name_Actions))
endfunction

