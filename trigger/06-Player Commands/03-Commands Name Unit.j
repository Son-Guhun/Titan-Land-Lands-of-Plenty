function Trig_Commands_Name_Unit_Func006A takes nothing returns nothing
    if ( GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() ) then
        call GUMSSetUnitName(GetEnumUnit(), Commands_GetArguments())
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit!")
    endif
endfunction

function Trig_Commands_Name_Unit_Actions takes nothing returns nothing
    local group g = CreateGroup()
    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    
    call ForGroup(g, function Trig_Commands_Name_Unit_Func006A )
    call DestroyGroup(g)
    set g = null
endfunction

//===========================================================================
function InitTrig_Commands_Name_Unit takes nothing returns nothing
    set gg_trg_Commands_Name_Unit = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Name_Unit, function Trig_Commands_Name_Unit_Actions )
endfunction

