function Trig_Commands_Copy_Func016A takes nothing returns nothing
    call GUMSCopyUnitSameType(GetEnumUnit(), GetTriggerPlayer())
endfunction

function Trig_Commands_Copy_Actions takes nothing returns nothing
    local group g = CreateGroup()  // Initialize group to get selected units
    local unit generator = null

    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)

    if GUDR_GeneratorHasGroup(FirstOfGroup(g))  then
        set generator = FirstOfGroup(g)
        call DestroyGroup(g)
        set g = GUDR_GetGeneratorGroup(generator)
    endif

    call GroupRemoveGroup( udg_System_ProtectedGroup, g )
    if CountUnitsInGroup(g) < 500 then
        call ForGroupBJ( g, function Trig_Commands_Copy_Func016A )
    else
        call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "You are attempting to copy too many units.\nMax: 500" )
    endif
    
    if generator == null then  // Don't destroy a RectGenerator's group...
        call DestroyGroup(g)
    else
        set generator = null
    endif
    set g = null
endfunction

//===========================================================================
function InitTrig_Commands_Copy takes nothing returns nothing
    set gg_trg_Commands_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Copy, function Trig_Commands_Copy_Actions )
endfunction

