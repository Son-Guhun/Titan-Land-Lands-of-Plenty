scope BreathOfFrost

public constant function SPELL_ID takes nothing returns integer
    return 'A05W'
endfunction

private constant function TOTAL_POINTS takes nothing returns integer
    return 8
endfunction

private function OnCast takes nothing returns nothing
    local real x = GetUnitX(udg_Spell__Caster)
    local real y = GetUnitY(udg_Spell__Caster)
    local real startAngle = Atan2(GetLocationY(udg_Spell__TargetPoint)-y, GetLocationX(udg_Spell__TargetPoint)-x )
    local integer circId = CreateGCOS(0, x, y, 200, 200, TOTAL_POINTS(), startAngle, 0)
    local unit dummy = DummyDmg_CreateDummy(udg_Spell__Caster, SPELL_ID(), 3.)
    
    call UnitAddAbility(dummy, 'A05X')
    
    call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,1), GetGCOSPointY(circId,1))
    call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,2), GetGCOSPointY(circId,2))
    call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,TOTAL_POINTS()), GetGCOSPointY(circId,TOTAL_POINTS()))
    
    call DestroyGCOS(circId)
    
    set dummy = null
endfunction

private function OnDamage takes nothing returns nothing
    set udg_TimerBonuses[CSS_BONUS_ATTACK_SPEED] = -25
    if IsUnitType(udg_DamageEventTarget, UNIT_TYPE_HERO) or IsUnitType(udg_DamageEventTarget, UNIT_TYPE_RESISTANT) then
        call AddTimedBonus(udg_DamageEventTarget, 0, 0.75, 4.0)
    else
        call AddTimedBonus(udg_DamageEventTarget, 0, 0.75, 8.0)
    endif
endfunction

//===========================================================================
function InitTrig_Breath_of_Frost takes nothing returns nothing
    set gg_trg_Breath_of_Frost = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Breath_of_Frost, function OnCast )
    
    call InitializeOnDamageTrigger(CreateTrigger(), 'A05W', function OnDamage)
endfunction
endscope

