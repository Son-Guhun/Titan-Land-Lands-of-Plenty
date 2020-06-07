scope CommandsCompat

private function onCommand takes nothing returns boolean
    local integer playerId = GetPlayerId(GetTriggerPlayer())
        
    set stringsLoaded[playerId + 1] = 0
    call SaveIO_LoadSaveOld(Player(playerId), SaveNLoad_OLDFOLDER() + LoP_Command.getArguments())
    
    return false
endfunction
//===========================================================================
function InitTrig_Commands_Compat takes nothing returns nothing
    call LoP_Command.create("-compat", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
