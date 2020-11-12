scope CommandsTest
/*
This command should be disabled for public releases. It's just here to make testing easier.
*/

private function SelectedUnitsTemplate takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer i

    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        // Do stuff
    endloop
    
    call DestroyGroup(g)
    set g = null
    set u = null
endfunction


private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local real asNum = Arguments_ParseNumber(args)
    local integer asPlayerNum = Commands_GetChatMessagePlayerNumber(args)
    
    
    // Do stuff
    call SelectedUnitsTemplate()
    
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Test takes nothing returns nothing
    call LoP_Command.create("-test", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope