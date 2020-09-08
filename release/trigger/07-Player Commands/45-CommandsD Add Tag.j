function Trig_CommandsD_Add_Tag_Func008A takes nothing returns nothing
    if not LoP_PlayerOwnsUnit(GetTriggerPlayer(), GetEnumUnit()) then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit." )
    else
        call GUMSAddUnitAnimationTag( GetEnumUnit() , LoP_Command.getArguments() )
    endif
endfunction

function Trig_CommandsD_Add_Tag_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    
    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    call ForGroup(g, function Trig_CommandsD_Add_Tag_Func008A )
    
    call DestroyGroup(g)

    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Add_Tag takes nothing returns nothing
    call LoP_Command.create("-tag", ACCESS_USER, Condition(function Trig_CommandsD_Add_Tag_Conditions))
endfunction

