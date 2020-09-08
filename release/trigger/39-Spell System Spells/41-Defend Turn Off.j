scope SpellDefendOff

private function onEffect takes nothing returns nothing
    local unit trigU = GetTriggerUnit()
    
    call UnitRemoveAbility(trigU, DEFEND_DUMMY)  // Disabling Elune's Grace does not negate the damage reduction, only reflect
    call BlzUnitHideAbility(trigU, DEFENDOFF, true)  // Disbaling berserk while a unit has the buff causes order bugs for some reason
    call BlzUnitHideAbility(trigU, DEFEND, false)
    call AddUnitAnimationProperties(trigU, "defend", false)
    call GMSS_UnitMultiplyMoveSpeed(trigU, 1/0.70)
    
    set trigU = null
endfunction

//===========================================================================
function InitTrig_Defend_Turn_Off takes nothing returns nothing
    call RegisterSpellSimple(DEFENDOFF, function onEffect, null)
endfunction

endscope
