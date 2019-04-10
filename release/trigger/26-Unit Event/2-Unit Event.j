//===========================================================================
function UnitEventDestroyGroup takes integer i returns nothing
    if udg_CargoTransportGroup[i] != null then
        call DestroyGroup(udg_CargoTransportGroup[i])
        set udg_CargoTransportGroup[i] = null
    endif
endfunction
function UnitEventCheckAfter takes nothing returns nothing
    local integer i = udg_CheckDeathList[0]
    set udg_CheckDeathList[0] = 0
    loop
        exitwhen i == 0
        if udg_IsUnitNew[i] then
            //The unit was just created.
            set udg_IsUnitNew[i] = false
        elseif udg_IsUnitTransforming[i] then
           //Added 21 July 2017 to fix the issue re-adding this ability in the same instant
           set udg_UDex = i
           set udg_UnitTypeEvent = 0.00
           set udg_UnitTypeEvent = 1.00
           set udg_UnitTypeOf[i] = GetUnitTypeId(udg_UDexUnits[i]) //Set this afterward to give the user extra reference
           set udg_IsUnitTransforming[i] = false
           call UnitAddAbility(udg_UDexUnits[i], udg_DetectTransformAbility)
        elseif udg_IsUnitAlive[i] then
            //The unit has started reincarnating.
            set udg_IsUnitReincarnating[i] = true
            set udg_IsUnitAlive[i] = false
            set udg_UDex = i
            set udg_DeathEvent = 0.50
            set udg_DeathEvent = 0.00
        endif
        set i = udg_CheckDeathList[i]
    endloop
endfunction
function UnitEventCheckAfterProxy takes integer i returns nothing
    if udg_CheckDeathList[0] == 0 then
        call TimerStart(udg_CheckDeathTimer, 0.00, false, function UnitEventCheckAfter)
    endif
    set udg_CheckDeathList[i] = udg_CheckDeathList[0]
    set udg_CheckDeathList[0] = i
endfunction

function UnitEventOnUnload takes nothing returns nothing
    local integer i = udg_UDex
    call GroupRemoveUnit(udg_CargoTransportGroup[GetUnitUserData(udg_CargoTransportUnit[i])], udg_UDexUnits[i])
    set udg_IsUnitBeingUnloaded[i] = true
    set udg_CargoEvent = 0.00
    set udg_CargoEvent = 2.00
    set udg_CargoEvent = 0.00
    set udg_IsUnitBeingUnloaded[i] = false
    if not IsUnitLoaded(udg_UDexUnits[i]) or IsUnitType(udg_CargoTransportUnit[i], UNIT_TYPE_DEAD) or GetUnitTypeId(udg_CargoTransportUnit[i]) == 0 then
        set udg_CargoTransportUnit[i] = null
    endif
endfunction

function UnitEventOnDeath takes nothing returns boolean
    local integer pdex = udg_UDex
    set udg_UDex = GetUnitUserData(GetTriggerUnit())
    if udg_UDex != 0 then
        set udg_KillerOfUnit[udg_UDex] = GetKillingUnit() //Added 29 May 2017 for GIMLI_2 
        set udg_IsUnitAlive[udg_UDex] = false
        set udg_DeathEvent = 0.00
        set udg_DeathEvent = 1.00
        set udg_DeathEvent = 0.00
        set udg_KillerOfUnit[udg_UDex] = null
        if udg_CargoTransportUnit[udg_UDex] != null then
            call UnitEventOnUnload()
        endif
    endif
    set udg_UDex = pdex
    return false
endfunction
  
function UnitEventOnOrder takes nothing returns boolean
    local integer pdex = udg_UDex
    local unit u = GetFilterUnit()
    local integer i = GetUnitUserData(u)
    if i > 0 then
        set udg_UDex = i
        if GetUnitAbilityLevel(u, udg_DetectRemoveAbility) == 0 then
            if not udg_IsUnitRemoved[i] then
                set udg_IsUnitRemoved[i] = true
                set udg_IsUnitAlive[i] = false
                set udg_SummonerOfUnit[i] = null
                
                //For backwards-compatibility:
                set udg_DeathEvent = 0.00
                set udg_DeathEvent = 3.00
                set udg_DeathEvent = 0.00
                
                //Fire deindex event for UDex:
                set udg_UnitIndexEvent = 0.00
                set udg_UnitIndexEvent = 2.00
                set udg_UnitIndexEvent = 0.00
                
                set udg_UDexNext[udg_UDexPrev[i]] = udg_UDexNext[i]
                set udg_UDexPrev[udg_UDexNext[i]] = udg_UDexPrev[i]
                
                // Recycle the index for later use
                set udg_UDexUnits[i] = null
                set udg_UDexPrev[i] = udg_UDexLastRecycled
                set udg_UDexLastRecycled = i
                call UnitEventDestroyGroup(i)
            endif
        elseif not udg_IsUnitAlive[i] then
            if not IsUnitType(u, UNIT_TYPE_DEAD) then
                set udg_IsUnitAlive[i] = true
                set udg_DeathEvent = 0.00
                set udg_DeathEvent = 2.00
                set udg_DeathEvent = 0.00
                set udg_IsUnitReincarnating[i] = false
            endif
        elseif IsUnitType(u, UNIT_TYPE_DEAD) then
            if udg_IsUnitNew[i] then
                //This unit was created as a corpse.
                set udg_IsUnitAlive[i] = false
                set udg_DeathEvent = 0.00
                set udg_DeathEvent = 1.00
                set udg_DeathEvent = 0.00
            elseif udg_CargoTransportUnit[i] == null or not IsUnitType(u, UNIT_TYPE_HERO) then
                //The unit may have just started reincarnating.
                call UnitEventCheckAfterProxy(i)
            endif
        elseif GetUnitAbilityLevel(u, udg_DetectTransformAbility) == 0 and not udg_IsUnitTransforming[i] then
            set udg_IsUnitTransforming[i] = true
            call UnitEventCheckAfterProxy(i)  //This block has been updated on 21 July 2017
        endif
        if udg_CargoTransportUnit[i] != null and not udg_IsUnitBeingUnloaded[i] and not IsUnitLoaded(u) or IsUnitType(u, UNIT_TYPE_DEAD) then
            call UnitEventOnUnload()
        endif
        set udg_UDex = pdex
    endif
    set u = null
    return false
endfunction
function UnitEventOnSummon takes nothing returns boolean
    local integer pdex = udg_UDex
    set udg_UDex = GetUnitUserData(GetTriggerUnit())
    if udg_IsUnitNew[udg_UDex] then
        set udg_SummonerOfUnit[udg_UDex] = GetSummoningUnit()
        set udg_UnitIndexEvent = 0.00
        set udg_UnitIndexEvent = 0.50
        set udg_UnitIndexEvent = 0.00
    endif
    set udg_UDex = pdex
    return false
endfunction
function UnitEventOnLoad takes nothing returns boolean
    local integer pdex = udg_UDex
    local integer i = GetUnitUserData(GetTriggerUnit())
    local integer index
    if i != 0 then
        set udg_UDex = i
        if udg_CargoTransportUnit[i] != null then
            call UnitEventOnUnload()
        endif
        //Loaded corpses do not issue an order when unloaded, therefore must
        //use the enter-region event method taken from Jesus4Lyf's Transport.
        if not udg_IsUnitAlive[i] then
            call SetUnitX(udg_UDexUnits[i], udg_WorldMaxX)
            call SetUnitY(udg_UDexUnits[i], udg_WorldMaxY)
        endif
        
        set udg_CargoTransportUnit[i] = GetTransportUnit()
        set index = GetUnitUserData(udg_CargoTransportUnit[i])
        if udg_CargoTransportGroup[index] == null then
            set udg_CargoTransportGroup[index] = CreateGroup()
        endif
        call GroupAddUnit(udg_CargoTransportGroup[index], udg_UDexUnits[i])
        set udg_CargoEvent = 0.00
        set udg_CargoEvent = 1.00
        set udg_CargoEvent = 0.00
        set udg_UDex = pdex
    endif
    return false
endfunction
function UnitEventEnter takes nothing returns boolean
    local integer pdex = udg_UDex
    local integer i = udg_UDexLastRecycled
    local unit u = GetFilterUnit()
    //IF UNIT AS DECORATION ABILITY, DO NOT INDEX THIS UNIT
    if LoP_IsUnitDecoration(u) then
        call SetUnitUserData(u, 0)
        set u = null
        return false
    endif
    if udg_UnitIndexerEnabled and GetUnitAbilityLevel(u, udg_DetectRemoveAbility) == 0 then
        //Generate a unique integer index for this unit
        if i == 0 then
            set i = udg_UDexMax + 1
            set udg_UDexMax = i
        else
            set udg_UDexLastRecycled = udg_UDexPrev[i]
        endif
        //Link index to unit, unit to index
        set udg_UDexUnits[i] = u
        call SetUnitUserData(u, i)
        
        //For backwards-compatibility, add the unit to a linked list
        set udg_UDexNext[i] = udg_UDexNext[0]
        set udg_UDexPrev[udg_UDexNext[0]] = i
        set udg_UDexNext[0] = i
        set udg_UDexPrev[i] = 0
        
        call UnitAddAbility(u, udg_DetectRemoveAbility)
        call UnitMakeAbilityPermanent(u, true, udg_DetectRemoveAbility)
        call UnitAddAbility(u, udg_DetectTransformAbility)
        set udg_UnitTypeOf[i] = GetUnitTypeId(u)
        set udg_IsUnitNew[i] = true
        set udg_IsUnitAlive[i] = true
        set udg_IsUnitRemoved[i] = false
        set udg_IsUnitReincarnating[i] = false
        set udg_IsUnitPreplaced[i] = udg_IsUnitPreplaced[0] //Added 29 May 2017 for Spellbound
        call UnitEventCheckAfterProxy(i)
        
        //Fire index event for UDex
        set udg_UDex = i
        set udg_UnitIndexEvent = 0.00
        set udg_UnitIndexEvent = 1.00
        set udg_UnitIndexEvent = 0.00
    else
        set udg_UDex = GetUnitUserData(u)
        if udg_CargoTransportUnit[udg_UDex] != null and not IsUnitLoaded(u) then
            //The unit was dead, but has re-entered the map.
            call UnitEventOnUnload()
        endif
    endif
    set udg_UDex = pdex
    set u = null
    return false
endfunction
//===========================================================================
function UnitEventInit takes nothing returns nothing
    local integer i = bj_MAX_PLAYER_SLOTS //update to make it work with 1.29 
    local player p
    local trigger t = CreateTrigger()
    local trigger load = CreateTrigger()
    local trigger death = CreateTrigger()
    local trigger summon = CreateTrigger()
    local rect r = GetWorldBounds()
    local region re = CreateRegion()
    local boolexpr enterB = Filter(function UnitEventEnter)
    local boolexpr orderB = Filter(function UnitEventOnOrder)
    set udg_WorldMaxX = GetRectMaxX(r)
    set udg_WorldMaxY = GetRectMaxY(r)
    call RegionAddRect(re, r)
    call RemoveRect(r)
    call UnitEventDestroyGroup(0)
    call UnitEventDestroyGroup(1)
    
    set udg_UnitIndexerEnabled = true
    call TriggerRegisterEnterRegion(CreateTrigger(), re, enterB)
    call TriggerAddCondition(load, Filter(function UnitEventOnLoad))
    call TriggerAddCondition(death, Filter(function UnitEventOnDeath))
    call TriggerAddCondition(summon, Filter(function UnitEventOnSummon))
    loop
        set i = i - 1
        set p = Player(i)
        call SetPlayerAbilityAvailable(p, udg_DetectRemoveAbility, false)
        call SetPlayerAbilityAvailable(p, udg_DetectTransformAbility, false)
        call TriggerRegisterPlayerUnitEvent(summon, p, EVENT_PLAYER_UNIT_SUMMON, null)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_ISSUED_ORDER, orderB)
        call TriggerRegisterPlayerUnitEvent(death, p, EVENT_PLAYER_UNIT_DEATH, null)
        call TriggerRegisterPlayerUnitEvent(load, p, EVENT_PLAYER_UNIT_LOADED, null)
        call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, p, enterB)
        exitwhen i == 0
    endloop
    set summon = null
    set death = null
    set load = null
    set re = null
    set enterB = null
    set orderB = null
    set p = null
    set r = null
    set t = null
endfunction
function InitTrig_Unit_Event takes nothing returns nothing
endfunction