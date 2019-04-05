function Trig_CommandsD_Add_Tag_Func008A takes nothing returns nothing
    if not LoP_PlayerOwnsUnit(GetTriggerPlayer(), GetEnumUnit()) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit." )
    else
        call GUMSAddUnitAnimationTag( GetEnumUnit() , Commands_GetArguments() )
    endif
endfunction

function Trig_CommandsD_Add_Tag_Actions takes nothing returns nothing
    local group g = CreateGroup()
    
    if Commands_StartsWithCommand() then
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
        call ForGroup(g, function Trig_CommandsD_Add_Tag_Func008A )
        
        call DestroyGroup(g)
    endif

    set g = null
endfunction

//===========================================================================
function InitTrig_CommandsD_Add_Tag takes nothing returns nothing
    set gg_trg_CommandsD_Add_Tag = CreateTrigger(  )
    call TriggerAddAction( gg_trg_CommandsD_Add_Tag, function Trig_CommandsD_Add_Tag_Actions )
endfunction

