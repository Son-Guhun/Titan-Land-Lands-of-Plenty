function Trig_CommandsD_Locust_Func011A takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    if not LoP_IsUnitDecoration(enumUnit) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "Only decorations may have be unselectable." )
        
    elseif not LoP_PlayerOwnsUnit(GetTriggerPlayer(), enumUnit) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit." )
        
    elseif CheckCommandOverflow() then
        call GUMSMakeUnitUnSelectable(enumUnit)
    endif
    set enumUnit = null
endfunction

function Trig_CommandsD_Locust_Conditions takes nothing returns boolean
    local group g

    if LoP_Command.getArguments() == "no" then
        set g = CreateGroup()
        
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
        set udg_Commands_Counter = 0
        set udg_Commands_Counter_Max = 500
        call ForGroup( g, function Trig_CommandsD_Locust_Func011A )
        
        call DestroyGroup(g)
        set g = null
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Locust takes nothing returns nothing
    call LoP_Command.create("-select", ACCESS_USER, Condition(function Trig_CommandsD_Locust_Conditions))
endfunction
