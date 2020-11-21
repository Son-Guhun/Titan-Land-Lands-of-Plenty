scope CosmosisObliterate

private function filterUnitsFunc takes nothing returns boolean
    local unit filterUnit = GetFilterUnit()
    
    if GUMS_GetUnitSelectionType(filterUnit) != 0 then
        if IsUnitInRangeXY(filterUnit, GetLocationX(udg_Spell__TargetPoint),  GetLocationY(udg_Spell__TargetPoint), 300.) then
            call LoP_RemoveUnit( filterUnit )
        endif
    endif
    
    
    set filterUnit = null
    return false
endfunction

private function onEffect takes nothing returns nothing
    local integer playerId = 0
    
    local LinkedHashSet_DecorationEffect decorations = EnumDecorationsInRange(GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 300.)
    local DecorationEffect deco = decorations.begin()
    
    loop
    exitwhen playerId == bj_MAX_PLAYERS
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerId), Filter(function filterUnitsFunc))
        set playerId = playerId + 1
    endloop
    

    loop
    exitwhen deco == decorations.end()
        call deco.destroy()
        set deco = decorations.next(deco)
    endloop
    call decorations.destroy()
endfunction

//===========================================================================
function InitTrig_Cosmosis_Obliterate takes nothing returns nothing
    call RegisterSpellSimple('A055', function onEffect, null)
endfunction

endscope
