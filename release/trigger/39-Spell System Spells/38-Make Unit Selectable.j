function Trig_Make_Unit_Selectable_Func003A takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    local unit newUnit
    local real unitX = GetUnitX(enumUnit)
    local real unitY = GetUnitY(enumUnit)
    local real locX = GetLocationX(udg_Spell__TargetPoint)
    local real locY = GetLocationY(udg_Spell__TargetPoint)
    if SquareRoot( (unitX-locX)*(unitX-locX) + (unitY-locY)*(unitY-locY)  ) <= 300. then
        if GUMS_GetUnitSelectionType(enumUnit) != 0 then
            set newUnit = GUMSCopyUnitSameType(enumUnit, GetOwningPlayer(enumUnit))
            if UnitHasAttachedEffect(enumUnit) then
                call UnitAttachEffect(newUnit, UnitDetachEffect(enumUnit))
            endif
            call KillUnit( enumUnit )
        endif
    endif
    
    set enumUnit = null
endfunction

function Trig_Make_Unit_Selectable_Actions takes nothing returns nothing
    local group udg_temp_group = CreateGroup()
    local unit u
    
    local LinkedHashSet_DecorationEffect decorations = EnumDecorationsOfPlayerInRange(GetOwningPlayer(GetTriggerUnit()), GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 300.)
    local DecorationEffect deco = decorations.begin()
    
    
    call GroupEnumUnitsOfPlayer(udg_temp_group, GetOwningPlayer(GetTriggerUnit()), null)
    call ForGroup( udg_temp_group, function Trig_Make_Unit_Selectable_Func003A )
    call DestroyGroup(udg_temp_group)
    

    loop
    exitwhen deco == decorations.end()
        if deco.pitch != 0 or deco.roll != 0 or deco.scaleY != deco.scaleX or deco.scaleZ != deco.scaleX then
            set u = Effect2Unit(deco)
            if UnitHasAttachedEffect(u) then
                call UnitDetachEffect(u).destroy()
            endif
            call UnitAttachEffect(u, deco.convertToSpecialEffect())
        else
            call Effect2Unit(deco)
            call deco.destroy()
        endif
        set deco = decorations.next(deco)
    endloop
    call decorations.destroy()
    
    set udg_temp_group = null
    set u = null
    return
endfunction

//===========================================================================
function InitTrig_Make_Unit_Selectable takes nothing returns nothing
    set gg_trg_Make_Unit_Selectable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Make_Unit_Selectable, function Trig_Make_Unit_Selectable_Actions )
endfunction

