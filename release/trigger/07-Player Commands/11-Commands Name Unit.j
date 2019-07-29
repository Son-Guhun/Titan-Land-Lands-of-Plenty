function Trig_Commands_Name_Unit_Func006A takes nothing returns nothing
    if ( GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() ) then
        call GUMSSetUnitName(GetEnumUnit(), LoP_Command.getArguments())
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit!")
    endif
endfunction

function Trig_Commands_Name_Unit_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    
    call ForGroup(g, function Trig_Commands_Name_Unit_Func006A )
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Name_Unit takes nothing returns nothing
    call LoP_Command.create("-nameunit", ACCESS_USER, Condition(function Trig_Commands_Name_Unit_Conditions ))
endfunction

