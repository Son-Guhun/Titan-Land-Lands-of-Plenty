function SpellId_CHAINSLOW takes nothing returns integer
    return 'A04C'
endfunction

function ChainSlowCastAction takes nothing returns nothing
    local unit dummy = DummyDmg_CreateDummy(udg_Spell__Caster, SpellId_CHAINSLOW(), 3.)
    local integer dummyKey = DummyDmg_GetKey(dummy)

    call DummyDmg_AddAbility(dummy, 'A04E')
    call DummyDmg_AddAbility(dummy, 'A04F')
    call IssueTargetOrder(dummy, "chainlightning", udg_Spell__Target)
        
    set dummy = null
endfunction

function ChainSlowDamageAction takes nothing returns boolean
    debug call BJDebugMsg("Chain Slow trigger fired!")
    call IssueTargetOrder(udg_DamageEventSource, "slow", udg_DamageEventTarget)
    return false
endfunction

function InitTrig_Chain_Slow takes nothing returns nothing
    call RegisterSpellSimple(SpellId_CHAINSLOW(), function ChainSlowCastAction, null)
    call InitializeOnDamageTrigger(CreateTrigger(), SpellId_CHAINSLOW(), function ChainSlowDamageAction)
endfunction

