function Trig_Commands_Copy_Func016A takes nothing returns nothing
    call GUMSCopyUnit(GetEnumUnit(), GetTriggerPlayer(),0)
endfunction

function Trig_Commands_Copy_Actions takes nothing returns nothing
    local group g = CreateGroup()  // Initialize group to get selected units
    local boolean destroyGrp = true

    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)

    if GUDR_GeneratorHasGroup(FirstOfGroup(g))  then
        set destroyGrp = false
        call DestroyGroup(g)
        set g = GUDR_GetGeneratorGroup(FirstOfGroup(g))
    endif

    call GroupRemoveGroup( udg_System_ProtectedGroup, g )
    if CountUnitsInGroup(g) < 500 then
        call ForGroupBJ( g, function Trig_Commands_Copy_Func016A )
    else
        call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "You are attempting to copy too many units.\nMax: 500" )
    endif
    
    if destroyGrp then
        call DestroyGroup(g)
    endif
    set g = null
endfunction

//===========================================================================
function InitTrig_Commands_Copy takes nothing returns nothing
    set gg_trg_Commands_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Copy, function Trig_Commands_Copy_Actions )
endfunction

