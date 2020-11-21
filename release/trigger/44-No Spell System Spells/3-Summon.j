// This trigger is supposed to handle all summoning spells, regarding anything that is related to the actual unit summoned or the summoner.

// It's not possible to directly determine the ability which was used to summon the unit.
// This can be an issue if multiple abilities can summon the same unit type.
scope SummonHandlingTrigger

globals
    private constant integer ARCHBISHOP_ANGELS_ABIL = 'A04O'
    private constant integer ARCHBISHOP_ANGELS_TYPE =  'h0H7'
    private constant integer ANGEL_REINCARNATION = 'A03O'
    
    private constant integer RoC_ARCHIMONDE = 'ANrc'
    private constant integer RoC_BALNAZZAR = 'ANr3'
    private constant integer INFERNAL_TYPE = 'n0G1'
endglobals

private function onSummon takes nothing returns nothing
    local unit summon = GetSummonedUnit()
    local unit summoner = GetSummoningUnit()

    if GetUnitTypeId(summon) == ARCHBISHOP_ANGELS_TYPE and GetUnitAbilityLevel(summoner, ARCHBISHOP_ANGELS_ABIL) != 0 then
        call UnitAddBonus(summon, BONUS_ARMOR, 4)
        call UnitAddBonus(summon, BONUS_ATTACK_SPEED, 25)
        call UnitAddBonus(summon, BONUS_DAMAGE, 20)
        call UnitRemoveAbility(summon, ANGEL_REINCARNATION)
    endif
    
    if GetUnitTypeId(summon) == INFERNAL_TYPE and GetUnitAbilityLevel(summoner, RoC_BALNAZZAR) + GetUnitAbilityLevel(summoner, RoC_ARCHIMONDE) > 0 then
        call UnitAddBonus(summon, BONUS_DAMAGE, -20)
        call UnitAddBonus(summon, BONUS_LIFE, -500)
    endif
    
    set summon = null
    set summoner = null
endfunction

//===========================================================================
function InitTrig_Summon takes nothing returns nothing
    set gg_trg_Summon = CreateTrigger(  )
    // call TriggerRegisterVariableEvent( gg_trg_Summon, "udg_UnitIndexEvent", EQUAL, 0.50 )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Summon, EVENT_PLAYER_UNIT_SUMMON)
    call TriggerAddAction( gg_trg_Summon, function onSummon )
endfunction

endscope
