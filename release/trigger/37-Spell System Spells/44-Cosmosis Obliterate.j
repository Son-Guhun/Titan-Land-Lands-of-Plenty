scope CosmosisObliterate

private function filterUnitsFunc takes nothing returns boolean
    local unit filterUnit = GetFilterUnit()
    local real unitX = GetUnitX(filterUnit)
    local real unitY = GetUnitY(filterUnit)
    local real locX = GetLocationX(udg_Spell__TargetPoint)
    local real locY = GetLocationY(udg_Spell__TargetPoint)
    
    if GUMS_GetUnitSelectionType(filterUnit) != 0 then
        if SquareRoot( (unitX-locX)*(unitX-locX) + (unitY-locY)*(unitY-locY)  ) <= 300. then
            call KillUnit( filterUnit )
        endif
    endif
    
    
    set filterUnit = null
    return false
endfunction

private function onCast takes nothing returns nothing
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
endfunction

//===========================================================================
function InitTrig_Cosmosis_Obliterate takes nothing returns nothing
    set gg_trg_Cosmosis_Obliterate = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Cosmosis_Obliterate, function onCast )
endfunction

endscope
