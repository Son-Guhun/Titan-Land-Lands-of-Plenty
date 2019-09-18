library DummyDmg requires ArrayAgent, TableStruct, optional DummyRecycler

globals
    public constant boolean RECYCLE = true
endglobals

private function GetDummy takes real x, real y returns unit
    static if not RECYCLE then
        return CreateUnit(GetOwningPlayer(spellCaster), 'h07Q', x, y, bj_UNIT_FACING)
    else
        return GetRecycledDummyAnyAngle(x, y, 0)
    endif
endfunction

function DummyDmg_ApplyTimedLife takes unit whichUnit, real timeout returns nothing
    static if not RECYCLE then
        call UnitApplyTimedLife(whichUnit, 'BTLF', timeout)
    else
        call DummyAddRecycleTimer(whichUnit, timeout)
    endif
endfunction

function DummyDmg_RemoveDummy takes unit whichUnit returns nothing
    static if not RECYCLE then
        call RemoveUnit(whichUnit)
    else
        call RecycleDummy(whichUnit)
    endif
endfunction


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

private struct DummyData extends array
    //! runtextmacro TableStruct_NewStructField("abilities", "LinkedHashSet")
    
    method hasAbilities takes nothing returns boolean
        return abilitiesExists()
    endmethod
    
    method clear takes nothing returns nothing
        call abilitiesClear()
    endmethod
    
    static method get takes unit whichUnit returns DummyData
        return GetHandleId(whichUnit)
    endmethod
endstruct

function DummyDmg_ClearData takes unit dummy returns nothing
    debug call Debug_PrintIf(DummyDmg_IsDummy(DummyDmg_GetKey(dummy)), "Dummy Data cleared!")
    debug call Debug_PrintIf(not DummyDmg_IsDummy(DummyDmg_GetKey(dummy)), "Cleared Dummy Data for none-dummy?!")
    
    static if RECYCLE then
        local integer abilCode
        local LinkedHashSet abilities
        local DummyData data = DummyData.get(dummy)
        
        if data.hasAbilities() then
            set abilities = data.abilities
            set abilCode = abilities.begin()
            loop
            exitwhen abilCode == abilities.end()
                call UnitRemoveAbility(dummy, abilCode)
                set abilCode = abilities.next(abilCode)
            endloop
            
            call abilities.destroy()
            call data.clear()  // if more data other than just abilities is added, move this out of if block
        endif
    endif
    
    call FlushChildHashtable(DummyDmg_HASHTABLE(), DummyDmg_GetKey(dummy))
endfunction

function DummyDmg_CreateDummyAt takes unit spellCaster, integer abilityId, real x, real y, real expiration returns unit
    local integer dummyKey
    local unit realSpellCaster = spellCaster  // save original spellCaster
    
    set spellCaster = GetDummy(x, y)  // spellCaster is actually the Dummy
    static if RECYCLE then
        call DummyDmg_ClearData(spellCaster)
        call SetUnitOwner(spellCaster, GetOwningPlayer(realSpellCaster), false)
    endif
    
    call BJDebugMsg(I2S(GetUnitUserData(spellCaster)))
    
    set dummyKey = DummyDmg_GetKey(spellCaster)
    
    call DummyDmg_SetCaster(dummyKey, realSpellCaster)
    if abilityId > 0 then
        call DummyDmg_SetAbility(dummyKey, abilityId)
    endif
    
    if expiration >= 0 then
        call DummyDmg_ApplyTimedLife(spellCaster, expiration)
    endif
    
    set realSpellCaster = null
    return spellCaster  // No need to null parameters
endfunction

function DummyDmg_CreateDummy takes unit spellCaster, integer abilityId, real expiration returns unit
    return DummyDmg_CreateDummyAt(spellCaster, abilityId, GetUnitX(spellCaster), GetUnitY(spellCaster), expiration)
endfunction

public function AddAbility takes unit whichUnit, integer abilCode returns nothing
    static if RECYCLE then
        local DummyData data = DummyData.get(whichUnit)
        
        
        if not data.hasAbilities() then
            set data.abilities = LinkedHashSet.create()
        endif
        
        if not data.abilities.contains(abilCode) then
            if UnitAddAbility(whichUnit, abilCode) then
                call data.abilities.append(abilCode)
            endif
        else
            call UnitAddAbility(whichUnit, abilCode)  // Just in case?
        endif
    else
        call UnitAddAbility(whichUnit, abilCode)
    endif
endfunction

endlibrary