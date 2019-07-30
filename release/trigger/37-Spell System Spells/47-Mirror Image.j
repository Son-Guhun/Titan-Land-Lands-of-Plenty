scope MirrorImage


private function onCast takes nothing returns nothing
    if GetUnitAbilityLevel(udg_Spell__Caster, 'AHer') > 0 and not IsUnitType(udg_Spell__Caster, UNIT_TYPE_HERO) then
        call DisplayTextToPlayer(GetOwningPlayer(udg_Spell__Caster), 0., 0., "Custom heroes cannot cast Mirror Image.")
        call IssueImmediateOrder(udg_Spell__Caster, "stop")        
    endif
endfunction

//===========================================================================
function InitTrig_Mirror_Image takes nothing returns nothing
    set gg_trg_Mirror_Image = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Mirror_Image, function onCast )
endfunction

endscope
