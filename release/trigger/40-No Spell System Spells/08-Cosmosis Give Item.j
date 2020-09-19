scope CosmosisGiveItem

private struct G extends array
    static key static_members_key
    //! runtextmacro TableStruct_NewConstTableField("public", "abil2Item")
endstruct


private function Actions takes nothing returns nothing
    local integer abilId = GetSpellAbilityId()

    if G.abil2Item.has(abilId) then
        call UnitAddItemByIdSwapped(G.abil2Item[abilId], GetSpellTargetUnit())
    endif
endfunction

//===========================================================================
function InitTrig_Cosmosis_Give_Item takes nothing returns nothing
    set gg_trg_Cosmosis_Give_Item = CreateTrigger(  )
    call TriggerRegisterUnitEvent( gg_trg_Cosmosis_Give_Item, HERO_COSMOSIS(), EVENT_UNIT_SPELL_EFFECT )
    call TriggerAddAction( gg_trg_Cosmosis_Give_Item, function Actions )
    
    set G.abil2Item['A04Q'] = 'I008'
    set G.abil2Item['A04I'] = 'I009'
    set G.abil2Item['A01A'] = 'I001'
endfunction

endscope

