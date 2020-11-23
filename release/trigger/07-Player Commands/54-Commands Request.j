scope CommandsRequest

private function onCommand takes nothing returns boolean
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string errorString = "Save not found under specified name. To load saves from before 1.4.0, use the |cffffff00-compat|r command."
    
    set stringsLoaded[playerId + 1] = 0
    
    // This block is only executed for the local player (async)
    if not SaveIO_LoadSave(Player(playerId), SaveNLoad_FOLDER() + LoP_Command.getArguments(), LoP_Command.getCommand() == "-req") then
        call LoP_WarnPlayer(User.Local, LoPChannels.ERROR, errorString)
    endif
    
    return false
endfunction
//===========================================================================
function InitTrig_Commands_Request takes nothing returns nothing
    call LoP_Command.create("-request", ACCESS_USER, Condition(function onCommand ))
    call LoP_Command.create("-req", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
