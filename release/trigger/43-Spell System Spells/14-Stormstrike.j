function StormStrikeGroupAction takes nothing returns nothing
    local unit u = GetEnumUnit()

    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldBuff.mdl", u, "origin"))
    
    set udg_TimerBonuses[CSS_BONUS_ARMOR] = -5
    set udg_TimerBonuses[CSS_BONUS_ATTACK_SPEED] = -75
    call AddTimedBonus(u, 0, 1, 3)

    call UnitDamageTarget(udg_Spell__Caster, u, 300, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
    
    set u = null
endfunction

function StormStrikeCastAction takes nothing returns nothing
    set udg_Spell__InRangePoint = udg_Spell__TargetPoint
    set udg_Spell__InRange = 100.00
    
    call ForGroup(udg_Spell__InRangeGroup, function StormStrikeGroupAction)
    
    call DestroyEffect(AddSpecialEffectLoc("Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl", udg_Spell__TargetPoint) )
endfunction
//===========================================================================
function InitTrig_Stormstrike takes nothing returns nothing
    set udg_Spell__Filter_AllowEnemy = true
    set udg_Spell__Filter_AllowLiving = true
    set udg_Spell__Filter_AllowHero = true
    set udg_Spell__Filter_AllowNonHero = true
    set udg_Spell__Filter_AllowFlying = false
    set udg_Spell__Filter_AllowMechanical = true
    set udg_Spell__Filter_AllowMagicImmune = false
    set udg_Spell__Filter_AllowStructure = false
    set udg_Spell__Filter_AllowAlly = false
    set udg_Spell__Filter_AllowDead = false
    
    set udg_Spell__Trigger_InRangeFilter = gg_trg_Spell_System_Filter_Decorations
    call RegisterSpellSimple('A04P', function StormStrikeCastAction, null)
endfunction

