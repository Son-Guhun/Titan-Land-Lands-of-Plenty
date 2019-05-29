scope CommandsCollision

private function OnCommand_GroupLoop takes nothing returns nothing
    local string args = LoP_Command.getArguments()
    if ( GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() ) then
        if args == "off" then
            call SetUnitPathing(GetEnumUnit(), false)
        elseif args == "on" then
            call SetUnitPathing(GetEnumUnit(), true)
        endif
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit!")
    endif
endfunction

private function OnCommand takes nothing returns boolean
    local group g = CreateGroup()
    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    
    call ForGroup(g, function OnCommand_GroupLoop )
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Collision takes nothing returns nothing
    call LoP_Command.create("-collision", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope
