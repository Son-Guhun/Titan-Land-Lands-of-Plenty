scope CritterWander

globals
    private constant integer ABILITY_ON = 'A056'
    private constant integer ABILITY_OFF = 'A05L'
endglobals
//ABILITY_SF_ICON_ACTIVATED
//ABILITY_SLF_ICON_NORMAL
//ABILITY_SLF_TOOLTIP_NORMAL
//ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED

//BlzSetAbilityStringField
//BlzSetAbilityStringLevelField
//BlzGetUnitAbility


private function onCast takes nothing returns nothing
    // local ability a = BlzGetUnitAbility(udg_Spell__Caster, ABILITY)
    
    if GetUnitAbilityLevel(udg_Spell__Caster, 'Awan') > 0 then
        call UnitAddAbility(udg_Spell__Caster, ABILITY_ON) // For some weird reason, this must be called before removing 'Awan'
        call UnitRemoveAbility(udg_Spell__Caster, 'Awan')
        call UnitRemoveAbility(udg_Spell__Caster, ABILITY_OFF)
  
        /*
        call BlzSetAbilityStringLevelField(a, ABILITY_SLF_TOOLTIP_NORMAL, 0, "Activate Wandering")
        call BlzSetAbilityStringLevelField(a, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1, "Makes this critter wander around aimlessly.")
        call BlzSetAbilityStringField(a, ABILITY_SF_ICON_ACTIVATED, "ReplaceableTextures\\CommandButtons\\BTNSelectUnit.blp")
        */
    else
        call UnitAddAbility(udg_Spell__Caster, 'Awan')
        call UnitAddAbility(udg_Spell__Caster, ABILITY_OFF)
        call UnitRemoveAbility(udg_Spell__Caster, ABILITY_ON)
        
        /*
        call BlzSetAbilityStringLevelField(a, ABILITY_SLF_TOOLTIP_NORMAL, 0, "Deactivate Wandering")
        call BlzSetAbilityStringLevelField(a, ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED, 1, "Makes this critter stand still.")
        call BlzSetAbilityStringField(a, ABILITY_SF_ICON_ACTIVATED, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp")
        */
    endif
    
    
endfunction

//===========================================================================
function InitTrig_Critter_Wander takes nothing returns nothing
    set gg_trg_Critter_Wander = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Critter_Wander, function onCast )
endfunction

endscope
