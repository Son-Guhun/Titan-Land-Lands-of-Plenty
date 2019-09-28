library LoPStdLib requires AttachedSFX, UnitVisualMods, LoPWidgets, LoPCommandsAbility

private function UnitAddAbilities takes unit whichUnit, LinkedHashSet abilities returns nothing
    local LinkedHashSet oldAbilities = UnitEnumRemoveableAbilityIds(whichUnit)
    local RemoveableAbility abilId = abilities.begin()
    
    
    call LoPCommandsAbility_ClearAbilities(whichUnit)
    loop
    exitwhen abilId == abilities.end()
        if abilId.isHero or oldAbilities.contains(abilId) then
            call UnitAddAbility(whichUnit, abilId)
        endif
        set abilId = abilities.next(abilId)
    endloop
    
    call abilities.destroy()
    call oldAbilities.destroy()
endfunction

function LopCopyUnit takes unit u, player owner, integer unitType returns unit
    local unit whichUnit = u
    
    set u = GUMSCopyUnit(whichUnit, owner, unitType)
    if UnitHasAttachedEffect(whichUnit) then
        call UnitAttachEffect(u, GetUnitAttachedEffect(whichUnit).copy(unitType))
    endif
    
    if LoP_IsUnitHero(whichUnit) then
        call UnitAddAbilities(u, UnitEnumRemoveableAbilityIds(whichUnit))
    endif
    
    set whichUnit = null
    return u
endfunction


function LopCopyUnitSameType takes unit whichUnit, player owner returns unit
    return LopCopyUnit(whichUnit, owner, GetUnitTypeId(whichUnit))
endfunction



endlibrary