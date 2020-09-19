scope CommandsTest
/*
This command should be disabled for public releases. It's just here to make testing easier.


*/

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local real asNum = Arguments_ParseNumber(args)
    local integer asPlayerNum = Commands_GetChatMessagePlayerNumber(args)
    
    // Do stuff
    
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Test takes nothing returns nothing
    call LoP_Command.create("-test", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope