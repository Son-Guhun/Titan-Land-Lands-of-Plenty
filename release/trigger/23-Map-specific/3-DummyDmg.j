library DummyDmg requires ArrayAgent, optional DummyRecycler

function InitializeOnDamageTrigger takes trigger whichTrigger, integer abilityId, code handlerFunc returns nothing
    if udg_Hashtable_2 == null then
        set udg_Hashtable_2  = InitHashtable()
    endif
    call TriggerAddCondition(whichTrigger, Condition(handlerFunc))
    call SaveTriggerHandle(udg_Hashtable_2, abilityId, 0, whichTrigger)
endfunction

//===========================================================================
// This system uses a hacky solution in order to keep Hashtable_1 and Hashtable_2 as free as possible:
// It uses the negative parent keys of ArrayAgent_Hashtable!!
// Using negative integers makes it so Dummies are fully compatible with the ArrayAgent system.
constant function DummyDmg_HASHTABLE takes nothing returns hashtable
    return ArrayAgent_hashTable
endfunction

function DummyDmg_GetKey takes unit whichUnit returns integer
    return -GetHandleId(whichUnit)
endfunction
//===========================================================================

function DummyDmg_ApplyTimedLife takes unit whichUnit, real timeout returns nothing
    //call UnitApplyTimedLife(whichUnit, 'BTLF', timeout + GetRandomReal(0,1))
    call DummyAddRecycleTimer(whichUnit, timeout)
endfunction

function DummyDmg_RemoveDummy takes unit whichUnit returns nothing
    // call RemoveUnit(whichUnit)
    call RecycleDummy(whichUnit)
endfunction

function DummyDmg_GetCaster takes integer dummyKey returns unit
    return LoadUnitHandle(DummyDmg_HASHTABLE(), dummyKey, 0)
endfunction

function DummyDmg_GetAbility takes integer dummyKey returns integer
    return LoadInteger(DummyDmg_HASHTABLE(),  dummyKey, 1)
endfunction

function DummyDmg_SetCaster takes integer dummyKey, unit whichUnit returns nothing
    call SaveUnitHandle(DummyDmg_HASHTABLE(), dummyKey, 0, whichUnit)
endfunction

function DummyDmg_SetAbility takes integer dummyKey, integer abilityId returns nothing
    call SaveInteger(DummyDmg_HASHTABLE(),  dummyKey, 1, abilityId)
endfunction

function DummyDmg_IsDummy takes integer dummyKey returns boolean
    return HaveSavedHandle(DummyDmg_HASHTABLE(), dummyKey, 0)
endfunction

function DummyDmg_HasTrigger takes integer dummyKey returns boolean
    return HaveSavedInteger(DummyDmg_HASHTABLE(), dummyKey, 1)
endfunction

function DummyDmg_FlushKey takes integer dummyKey returns nothing
    debug call Debug_PrintIf(DummyDmg_IsDummy(dummyKey), "Dummy Data cleared!")
    debug call Debug_PrintIf(not DummyDmg_IsDummy(dummyKey), "Cleared Dummy Data for none-dummy?!")
    call FlushChildHashtable(DummyDmg_HASHTABLE(), dummyKey)
endfunction

function DummyDmg_CreateDummyEx takes unit spellCaster, integer unitId, integer abilityId, real x, real y, real expiration returns unit
    local integer dummyKey
    local unit realSpellCaster = spellCaster  // spellCaster is actually the Dummy
    
    //set spellCaster = CreateUnit(GetOwningPlayer(spellCaster), unitId, x, y, bj_UNIT_FACING)
    set spellCaster = GetRecycledDummyAnyAngle(x, y, 0)
    call DummyDmg_FlushKey(DummyDmg_GetKey(spellCaster))
    call PauseUnit(spellCaster, false)
    call SetUnitOwner(spellCaster, GetOwningPlayer(realSpellCaster), false)
    
    set dummyKey = DummyDmg_GetKey(spellCaster)
    
    call DummyDmg_SetCaster(dummyKey, realSpellCaster)
    if abilityId > 0 then
        call DummyDmg_SetAbility(dummyKey, abilityId)
    endif
    
    if expiration >= 0 then
        call DummyDmg_ApplyTimedLife(spellCaster, expiration)
    endif
    
    set realSpellCaster = null
    return spellCaster  // No need to null paramters
endfunction


function DummyDmg_CreateDummyAt takes unit spellCaster, integer abilityId, real x, real y, real expiration returns unit
    return DummyDmg_CreateDummyEx(spellCaster, 'h07Q', abilityId, x, y, expiration)
endfunction

function DummyDmg_CreateDummy takes unit spellCaster, integer abilityId, real expiration returns unit
    return DummyDmg_CreateDummyAt(spellCaster, abilityId, GetUnitX(spellCaster), GetUnitY(spellCaster), expiration)
endfunction


endlibrary