/* Attempted base abilities:
    - Item abilities => Good because there is no chance of order conflicts.
        'AIp1' => Has delay
        'AIha' => Has delay, shares order with 'AIpz'
        'AIre' => cannot use at full HP
        'AIrv' => Interrupts order
        'APdi' => Is not instant order?!
        'AIsp' => Has delay
        'Aret' => Only heroes, no abilties on CD
*/
globals
    constant integer DEFEND = 'A02S'
    constant integer DEFENDOFF = 'A02X'
    constant integer DEFEND_DUMMY = 'A02C'
endglobals

function Trig_Defend_Turn_On_Actions takes nothing returns nothing
    local unit trigU = GetTriggerUnit()
    
    if ( GetUnitAbilityLevel(trigU, DEFEND_DUMMY) == 0 ) then
        call UnitAddAbility(trigU, DEFEND_DUMMY)
    else
        call BlzUnitDisableAbility(trigU, DEFEND_DUMMY,false,false)
    endif
    if ( GetUnitAbilityLevel(trigU, DEFENDOFF) == 0 ) then
        call UnitAddAbility(trigU, DEFENDOFF)
    else
        call BlzUnitHideAbility(trigU,DEFENDOFF, false)
    endif
    
    call BlzUnitHideAbility(trigU, DEFEND_DUMMY, true)
    call BlzUnitHideAbility(trigU, DEFEND, true)
    
    call AddUnitAnimationProperties(trigU, "defend", true)
    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", trigU, "origin"))
    call GMSS_UnitMultiplyMoveSpeed(trigU, 0.70)
    
    set trigU = null
endfunction

//===========================================================================
function InitTrig_Defend_Turn_On takes nothing returns nothing
    set gg_trg_Defend_Turn_On = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Defend_Turn_On, function Trig_Defend_Turn_On_Actions )
endfunction

