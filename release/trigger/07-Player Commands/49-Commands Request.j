scope CommandsRequest

private function onCommand takes nothing returns boolean
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string chatStr = GetEventPlayerChatString()
        
    set udg_load_number[playerId + 1] = 0
    call SaveIO_LoadSave(Player(playerId), SaveNLoad_FOLDER() + SubString(chatStr,9,129))
    
    return false
endfunction
//===========================================================================
function InitTrig_Commands_Request takes nothing returns nothing
    call LoP_Command.create("-request", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
