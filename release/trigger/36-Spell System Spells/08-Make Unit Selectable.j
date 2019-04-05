function Trig_Make_Unit_Selectable_Func003A takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    local real unitX = GetUnitX(enumUnit)
    local real unitY = GetUnitY(enumUnit)
    local real locX = GetLocationX(udg_Spell__TargetPoint)
    local real locY = GetLocationY(udg_Spell__TargetPoint)
    if SquareRoot( (unitX-locX)*(unitX-locX) + (unitY-locY)*(unitY-locY)  ) <= 300 then
        if GUMS_GetUnitSelectionType(enumUnit) != 0 then
            call GUMSMakeUnitSelectable(enumUnit)
            call KillUnit( enumUnit )
        endif
    endif
    
    set enumUnit = null
endfunction

function Trig_Make_Unit_Selectable_Actions takes nothing returns nothing
    local group udg_temp_group = CreateGroup()
    call GroupEnumUnitsOfPlayer(udg_temp_group, GetOwningPlayer(GetTriggerUnit()), null)
    call ForGroup( udg_temp_group, function Trig_Make_Unit_Selectable_Func003A )
    call DestroyGroup(udg_temp_group)
    set udg_temp_group = null
    return
endfunction

//===========================================================================
function InitTrig_Make_Unit_Selectable takes nothing returns nothing
    set gg_trg_Make_Unit_Selectable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Make_Unit_Selectable, function Trig_Make_Unit_Selectable_Actions )
endfunction

