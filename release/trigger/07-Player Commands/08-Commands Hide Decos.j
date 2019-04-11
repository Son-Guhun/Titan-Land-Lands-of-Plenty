function Trig_Commands_Hide_Decos_Func006A takes nothing returns nothing
    if LoP_IsUnitDecoBuilder(GetEnumUnit()) then
        call ShowUnit(GetEnumUnit(), false)
    endif
endfunction

function Trig_Commands_Hide_Decos_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local group g = CreateGroup()
    
    if ( args == "all" ) then
        set g = CreateGroup()
        call GroupEnumUnitsOfPlayer(g, GetTriggerPlayer(), null)
    else
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    endif
    call ForGroup(g, function Trig_Commands_Hide_Decos_Func006A)
    
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Hide_Decos takes nothing returns nothing
    call LoP_Command.create("-hide", ACCESS_USER, Condition(function Trig_Commands_Hide_Decos_Conditions))
endfunction

