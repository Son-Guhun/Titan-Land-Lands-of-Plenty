scope MirrorImage


private function onCast takes nothing returns nothing
    if GetUnitAbilityLevel(udg_Spell__Caster, 'AHer') > 0 and not IsUnitType(udg_Spell__Caster, UNIT_TYPE_HERO) then
        call LoP_WarnPlayer(GetOwningPlayer(udg_Spell__Caster), LoPChannels.ERROR, "Custom heroes cannot cast Mirror Image.")
        call IssueImmediateOrder(udg_Spell__Caster, "stop")        
    elseif GetUnitAbilityLevel(udg_Spell__Caster, 'AEme') + GetUnitAbilityLevel(udg_Spell__Caster, 'AEvi') + GetUnitAbilityLevel(udg_Spell__Caster, 'AEll') + GetUnitAbilityLevel(udg_Spell__Caster, 'A067') + GetUnitAbilityLevel(udg_Spell__Caster, 'A066') + GetUnitAbilityLevel(udg_Spell__Caster, 'A065')> 0 then
        call LoP_WarnPlayer(GetOwningPlayer(udg_Spell__Caster), LoPChannels.ERROR, "Heroes with Metamorphosis cannot cast Mirror Image.")
        call IssueImmediateOrder(udg_Spell__Caster, "stop")
        call UnitRemoveAbility(udg_Spell__Caster, 'AOmi')  // Removing it before issuing stop order will make the hero duplicate (apparently) correctly. However, I would rather avoid any obscure bugs that might arise because of this.
    endif
endfunction

//===========================================================================
function InitTrig_Mirror_Image takes nothing returns nothing
    call RegisterSpellSimpleOnCast('AOmi', function onCast, null)
endfunction

endscope
