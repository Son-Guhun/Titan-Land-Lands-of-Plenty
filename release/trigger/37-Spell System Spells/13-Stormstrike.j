function StormStrikeGroupAction takes nothing returns nothing
    local unit u = GetEnumUnit()

    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldBuff.mdl", u, "origin"))
    
    set udg_TimerBonuses[CSS_ARMOR] = -5
    set udg_TimerBonuses[CSS_ATKSPEED] = -75
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

    set gg_trg_Stormstrike = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Stormstrike, function StormStrikeCastAction )

endfunction

