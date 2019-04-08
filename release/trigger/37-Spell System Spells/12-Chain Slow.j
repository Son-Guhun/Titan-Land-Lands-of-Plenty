function SpellId_CHAINSLOW takes nothing returns integer
    return 'A04C'
endfunction

function ChainSlowCastAction takes nothing returns nothing
    local unit dummy = DummyDmg_CreateDummy(udg_Spell__Caster, SpellId_CHAINSLOW(), 3.)
    local integer dummyKey = DummyDmg_GetKey(dummy)

    call UnitAddAbility(dummy, 'A04E')
    call UnitAddAbility(dummy, 'A04F')
    call IssueTargetOrder(dummy, "chainlightning", udg_Spell__Target)
        
    set dummy = null
endfunction


//CreateUnit(udg_Spell__CasterOwner, 'h07Q', GetUnitX(udg_Spell__Caster), GetUnitY(udg_Spell__Caster), 270)//GetRecycledDummy(GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 0, 270)

//===========================================================================
function ChainSlowDamageAction takes nothing returns boolean
    debug call BJDebugMsg("Chain Slow trigger fired!")
    call IssueTargetOrder(udg_DamageEventSource, "slow", udg_DamageEventTarget)
    return false
endfunction

function InitTrig_Chain_Slow takes nothing returns nothing
    set gg_trg_Chain_Slow = CreateTrigger()
    call TriggerAddAction(gg_trg_Chain_Slow, function ChainSlowCastAction)

    //Hero - Chain Slow: Cast Slow on damaged units
    call InitializeOnDamageTrigger(CreateTrigger(), SpellId_CHAINSLOW(), function ChainSlowDamageAction)
    //-------------------------------------------------
endfunction

