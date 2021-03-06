scope CommandsCollision

private function OnCommand_GroupLoop takes nothing returns nothing
    local string args = LoP_Command.getArguments()
    if ( GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() ) then
    
        if LoP_IsUnitDecoration(GetEnumUnit()) then
            if args == "off" then
                call IssueImmediateOrder(GetEnumUnit(), "thunderclap")
            elseif args == "on" then
                call IssueImmediateOrder(GetEnumUnit(), "thunderbolt")
            endif
        else
            if args == "off" then
                call SetUnitPathing(GetEnumUnit(), false)
            elseif args == "on" then
                call SetUnitPathing(GetEnumUnit(), true)
            endif
        endif
    else
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
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
