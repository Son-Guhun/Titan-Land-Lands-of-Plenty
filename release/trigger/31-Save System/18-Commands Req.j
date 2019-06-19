scope CommandsRequest

private function OnCommand takes nothing returns boolean
    call LoadRequest(GetTriggerPlayer(), LoP_Command.getArguments())
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Req takes nothing returns nothing
    call LoP_Command.create("-req", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope
