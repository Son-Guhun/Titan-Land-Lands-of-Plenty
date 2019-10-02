scope MirrorImage


private function onCast takes nothing returns nothing
    if GetUnitAbilityLevel(udg_Spell__Caster, 'AHer') > 0 and not IsUnitType(udg_Spell__Caster, UNIT_TYPE_HERO) then
        call DisplayTextToPlayer(GetOwningPlayer(udg_Spell__Caster), 0., 0., "Custom heroes cannot cast Mirror Image.")
        call IssueImmediateOrder(udg_Spell__Caster, "stop")        
    elseif GetUnitAbilityLevel(udg_Spell__Caster, 'AEme') + GetUnitAbilityLevel(udg_Spell__Caster, 'AEvi') + GetUnitAbilityLevel(udg_Spell__Caster, 'AEll') > 0 then
        call UnitRemoveAbility(udg_Spell__Caster, 'AOmi')
        call DisplayTextToPlayer(GetOwningPlayer(udg_Spell__Caster),0,0, "Heroes with Metamorphosis cannot cast Mirror Image.")
        call IssueImmediateOrder(udg_Spell__Caster, "stop")
    endif
endfunction

//===========================================================================
function InitTrig_Mirror_Image takes nothing returns nothing
    set gg_trg_Mirror_Image = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Mirror_Image, function onCast )
endfunction

endscope
