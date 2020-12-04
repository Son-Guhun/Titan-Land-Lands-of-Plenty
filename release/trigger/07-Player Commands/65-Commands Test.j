scope CommandsTest
/*
This command should be disabled for public releases. It's just here to make testing easier.
*/

private function AddPathingMap takes unit u returns nothing
    local ArrayList_string args = StringSplitWS(LoP_Command.getArgumentsRaw())
    
    set DefaultPathingMap.fromTypeOfUnit(u).path = PathingMap.getGeneric(S2I(args[0]), S2I(args[1]))
    call DefaultPathingMap.fromTypeOfUnit(u).update(u, GetUnitX(u), GetUnitY(u), GetUnitFacing(u)*bj_DEGTORAD)
    
    call args.destroy()
endfunction

private function SelectedUnitsTemplate takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer i

    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        // Do stuff
        call AddPathingMap(u)
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