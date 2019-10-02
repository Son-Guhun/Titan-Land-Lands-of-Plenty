scope MakeUnitsSeletable

private function MakeLocustUnitsSelectable takes nothing returns nothing
    local group g = CreateGroup()
    local real locX = GetLocationX(udg_Spell__TargetPoint)
    local real locY = GetLocationY(udg_Spell__TargetPoint)
    local unit u
    local real unitX
    local real unitY
    local unit newUnit
    local boolean includeDecos = udg_Spell__Ability != 'A01S'

    call GroupEnumUnitsOfPlayer(g, udg_Spell__CasterOwner, null)

    loop
        //! runtextmacro ForUnitInGroup("u", "g")
        if GUMS_GetUnitSelectionType(u) != 0 then
            set unitX = GetUnitX(u)
            set unitY = GetUnitY(u)
            if SquareRoot( (unitX-locX)*(unitX-locX) + (unitY-locY)*(unitY-locY)  ) <= 300. then
                if LoP_IsUnitDecoration(u) then
                    if includeDecos then
                        set newUnit = GUMSCopyUnitSameType(u, GetOwningPlayer(u))
                        if UnitHasAttachedEffect(u) then
                            call UnitAttachEffect(newUnit, UnitDetachEffect(u))
                        endif
                        call KillUnit(u)
                    endif
                else
                    call GUMSCopyUnitSameType(u, GetOwningPlayer(u))
                    call RemoveUnit(u)
                endif
            endif    
        endif
    endloop

    call DestroyGroup(g)
    set g = null
    set u = null
    set newUnit = null
endfunction

private function onCast takes nothing returns nothing
    local unit u
    local LinkedHashSet_DecorationEffect decorations
    local DecorationEffect deco
    
    call ExecuteCode(function MakeLocustUnitsSelectable)

    if udg_Spell__Ability != 'A01S' then
        set decorations = EnumDecorationsOfPlayerInRange(GetOwningPlayer(GetTriggerUnit()), GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 300.)
        set deco = decorations.begin()
        
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
    endif
    
    set u = null
endfunction

//===========================================================================
function InitTrig_Make_Unit_Selectable takes nothing returns nothing
    set gg_trg_Make_Unit_Selectable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Make_Unit_Selectable, function onCast )
endfunction

endscope
