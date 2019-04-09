//===========================================================================
// Damage Engine lets you detect, amplify, block or nullify damage. It even
// lets you detect if the damage was physical or from a spell. Just reference
// DamageEventAmount/Source/Target or the boolean IsDamageSpell, to get the
// necessary damage event data.
//
// - Detect damage: use the event "DamageEvent Equal to 1.00"
// - To change damage before it's dealt: use the event "DamageModifierEvent Equal to 1.00"
// - Detect damage after it was applied, use the event "AfterDamageEvent Equal to 1.00"
// - Detect spell damage: use the condition "IsDamageSpell Equal to True"
// - Detect zero-damage: use the event "DamageEvent Equal to 2.00" (an AfterDamageEvent will not fire for this)
//
// You can specify the DamageEventType before dealing triggered damage. To prevent an already-improbable error, I recommend running the trigger "ClearDamageEvent (Checking Conditions)" after dealing triggered damage from within a damage event:
// - Set NextDamageType = DamageTypeWhatever
// - Unit - Cause...
// - Trigger - Run ClearDamageEvent (Checking Conditions)
//
// You can modify the DamageEventAmount and the DamageEventType from a "DamageModifierEvent Equal to 1.00" trigger.
// - If the amount is modified to negative, it will count as a heal.
// - If the amount is set to 0, no damage will be dealt.
//
// If you need to reference the original in-game damage, use the variable "DamageEventPrevAmt".
//
//===========================================================================
// Programming note about "integer i" and "udg_DmgEvRecursionN": integer i
// ranges from -1 upwards. "udg_DmgEvRecursionN" ranges from 0 upwards.
// "integer i" is always 1 less than "udg_DmgEvRecursionN"
//

// EDITS BY GUHUN (look for GuhunEdit_ prefix)

function DmgEvResetVars takes nothing returns nothing
    local integer i = udg_DmgEvRecursionN - 2
    set udg_DmgEvRecursionN = i + 1
    if i >= 0 then
        set udg_DamageEventPrevAmt  = udg_LastDmgPrevAmount[i]
        set udg_DamageEventAmount   = udg_LastDmgValue[i]
        set udg_DamageEventSource   = udg_LastDmgSource[i]
        set udg_DamageEventTarget   = udg_LastDmgTarget[i]
        set udg_IsDamageSpell       = udg_LastDmgWasSpell[i]
        set udg_DamageEventType     = udg_LastDmgPrevType[i]
    endif
endfunction
function CheckDamagedLifeEvent takes boolean clear returns nothing
    if clear then
        set udg_NextDamageOverride = false
        set udg_NextDamageType = 0
    endif
    if udg_DmgEvTrig != null then
        call DestroyTrigger(udg_DmgEvTrig)
        set udg_DmgEvTrig = null
        if udg_IsDamageSpell then
            call SetWidgetLife(udg_DamageEventTarget, RMaxBJ(udg_LastDamageHP, 0.41))
            if udg_LastDamageHP <= 0.405 then
                if udg_DamageEventType < 0 then
                    call SetUnitExploded(udg_DamageEventTarget, true)
                endif
                //Kill the unit
                call DisableTrigger(udg_DamageEventTrigger)
                call UnitDamageTarget(udg_DamageEventSource, udg_DamageEventTarget, -999, false, false, null, DAMAGE_TYPE_UNIVERSAL, null)
                call EnableTrigger(udg_DamageEventTrigger)
            endif
        elseif GetUnitAbilityLevel(udg_DamageEventTarget, udg_DamageBlockingAbility) > 0 then
            call UnitRemoveAbility(udg_DamageEventTarget, udg_DamageBlockingAbility)
            call SetWidgetLife(udg_DamageEventTarget, udg_LastDamageHP)
        endif
        if udg_DamageEventAmount != 0.00 and not udg_HideDamageFrom[GetUnitUserData(udg_DamageEventSource)] then
            set udg_AfterDamageEvent = 0.00
            set udg_AfterDamageEvent = 1.00
            set udg_AfterDamageEvent = 0.00
        endif
        call DmgEvResetVars()
    endif
endfunction
   
function DmgEvOnAOEEnd takes nothing returns nothing
    if udg_DamageEventAOE > 1 then
        set udg_AOEDamageEvent = 0.00
        set udg_AOEDamageEvent = 1.00
        set udg_AOEDamageEvent = 0.00
        set udg_DamageEventAOE = 1
    endif
    set udg_DamageEventLevel = 1
    set udg_EnhancedDamageTarget = null
    call GroupClear(udg_DamageEventAOEGroup)
endfunction
   
function DmgEvOnExpire takes nothing returns nothing
    set udg_DmgEvStarted = false
    call CheckDamagedLifeEvent(true)
    //Reset things so they don't perpetuate for AoE/Level target detection
    call DmgEvOnAOEEnd()
    set udg_DamageEventTarget = null
    set udg_DamageEventSource = null
endfunction
function PreCheckDamagedLifeEvent takes nothing returns boolean
    call CheckDamagedLifeEvent(true)
    return false
endfunction
function OnUnitDamage takes nothing returns boolean
    local boolean override = udg_DamageEventOverride
    local integer i
    local integer e = udg_DamageEventLevel
    local integer a = udg_DamageEventAOE
    local string s
    local real prevAmount
    local real life
    local real prevLife
    local unit u
    local unit f
    call CheckDamagedLifeEvent(false) //in case the unit state event failed and the 0.00 second timer hasn't yet expired
    set i = udg_DmgEvRecursionN - 1 //Had to be moved here due to false recursion tracking
    if i < 0 then
        //Added 25 July 2017 to detect AOE damage or multiple single-target damage
        set u                       = udg_DamageEventTarget
        set f                       = udg_DamageEventSource
    elseif i < 16 then
        set udg_LastDmgPrevAmount[i]= udg_DamageEventPrevAmt
        set udg_LastDmgValue[i]     = udg_DamageEventAmount
        set udg_LastDmgSource[i]    = udg_DamageEventSource
        set udg_LastDmgTarget[i]    = udg_DamageEventTarget
        set udg_LastDmgWasSpell[i]  = udg_IsDamageSpell
        set udg_LastDmgPrevType[i]  = udg_DamageEventType
    else
        set s = "WARNING: Recursion error when dealing damage! Make sure when you deal damage from within a DamageEvent trigger, do it like this:\n\n"
        set s = s + "Trigger - Turn off (This Trigger)\n"
        set s = s + "Unit - Cause...\n"
        set s = s + "Trigger - Turn on (This Trigger)"
       
        //Delete the next couple of lines to disable the in-game recursion crash warnings
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 10., s)
        return false
    endif
    set udg_DmgEvRecursionN     = i + 2
    set prevAmount              = GetEventDamage()
    set udg_DamageEventTarget   = GetTriggerUnit()
    set udg_DamageEventSource   = GetEventDamageSource()
   
    set udg_DamageEventAmount   = prevAmount
   
    set udg_DamageEventType     = udg_NextDamageType
    set udg_NextDamageType      = 0
    set udg_DamageEventOverride = udg_NextDamageOverride
    set udg_NextDamageOverride  = false
   
    if i < 0 then
        //Added 25 July 2017 to detect AOE damage or multiple single-target damage
        if udg_DamageEventType == 0 then
            if f == udg_DamageEventSource then
                //Source has damaged more than once
                if IsUnitInGroup(udg_DamageEventTarget, udg_DamageEventAOEGroup) then
                    //Added 5 August 2017 to improve tracking of enhanced damage against, say, Pulverize
                    set udg_DamageEventLevel = udg_DamageEventLevel + 1
                    set udg_EnhancedDamageTarget = udg_DamageEventTarget
                else
                    //Multiple targets hit by this source - flag as AOE
                    set udg_DamageEventAOE = udg_DamageEventAOE + 1
                endif
            else
                //New damage source - unflag everything
                set u = udg_DamageEventSource
                set udg_DamageEventSource = f
                call DmgEvOnAOEEnd()
                set udg_DamageEventSource = u
            endif
            call GroupAddUnit(udg_DamageEventAOEGroup, udg_DamageEventTarget)
        endif
        if not udg_DmgEvStarted then
            set udg_DmgEvStarted = true
            call TimerStart(udg_DmgEvTimer, 0.00, false, function DmgEvOnExpire)
        endif
    endif
   
    if prevAmount == 0.00 then
        if not udg_HideDamageFrom[GetUnitUserData(udg_DamageEventSource)] then
            set udg_DamageEventPrevAmt = 0.00
            set udg_DamageEvent = 0.00
            set udg_DamageEvent = 2.00
            set udg_DamageEvent = 0.00
        endif
        call DmgEvResetVars()
    else
        set u = udg_DamageEventTarget
        set udg_IsDamageSpell = prevAmount < 0.00
        if udg_IsDamageSpell then
            set prevAmount = -udg_DamageEventAmount
            set life = 1.00
            if IsUnitType(u, UNIT_TYPE_ETHEREAL) and not IsUnitType(u, UNIT_TYPE_HERO) then
                set life = life*udg_DAMAGE_FACTOR_ETHEREAL //1.67
            endif
            if GetUnitAbilityLevel(u, 'Aegr') > 0 then
                set life = life*udg_DAMAGE_FACTOR_ELUNES //0.80
            endif
            if udg_DmgEvBracers != 0 and IsUnitType(u, UNIT_TYPE_HERO) then
                //Inline of UnitHasItemOfTypeBJ without the potential handle ID leak.
                set i = 6
                loop
                    set i = i - 1
                    if GetItemTypeId(UnitItemInSlot(u, i)) == udg_DmgEvBracers then
                        set life = life*udg_DAMAGE_FACTOR_BRACERS //0.67
                        exitwhen true
                    endif
                    exitwhen i == 0
                endloop
            endif
            set udg_DamageEventAmount = prevAmount*life
        endif
        set udg_DamageEventPrevAmt = prevAmount
        set udg_DamageModifierEvent = 0.00
        if not udg_DamageEventOverride then
            set udg_DamageModifierEvent = 1.00
            if not udg_DamageEventOverride then
                set udg_DamageModifierEvent = 2.00
                set udg_DamageModifierEvent = 3.00
            endif
        endif
        set udg_DamageEventOverride = override
        if udg_DamageEventAmount > 0.00 then
            set udg_DamageModifierEvent = 4.00
        endif
        set udg_DamageModifierEvent = 0.00
        if not udg_HideDamageFrom[GetUnitUserData(udg_DamageEventSource)] then
            set udg_DamageEvent = 0.00
            set udg_DamageEvent = 1.00
            set udg_DamageEvent = 0.00
        endif
        call CheckDamagedLifeEvent(true) //in case the unit state event failed from a recursive damage event
       
        //All events have run and the damage amount is finalized.
        set life = GetWidgetLife(u)
        set udg_DmgEvTrig = CreateTrigger()
        call TriggerAddCondition(udg_DmgEvTrig, Filter(function PreCheckDamagedLifeEvent))
        if not udg_IsDamageSpell then
            if udg_DamageEventAmount != prevAmount then
                set life = life + prevAmount - udg_DamageEventAmount
                if GetUnitState(u, UNIT_STATE_MAX_LIFE) < life then
                    set udg_LastDamageHP = life - prevAmount
                    call UnitAddAbility(u, udg_DamageBlockingAbility)
                endif
                call SetWidgetLife(u, RMaxBJ(life, 0.42))
            endif
            call TriggerRegisterUnitStateEvent(udg_DmgEvTrig, u, UNIT_STATE_LIFE, LESS_THAN, RMaxBJ(0.41, life - prevAmount/2.00))
        else
            set udg_LastDamageHP = GetUnitState(u, UNIT_STATE_MAX_LIFE)
            set prevLife = life
            if life + prevAmount*0.75 > udg_LastDamageHP then
                set life = RMaxBJ(udg_LastDamageHP - prevAmount/2.00, 1.00)
                call SetWidgetLife(u, life)
                set life = (life + udg_LastDamageHP)/2.00
            else
                set life = life + prevAmount*0.50
            endif
            set udg_LastDamageHP = prevLife - (prevAmount - (prevAmount - udg_DamageEventAmount))
            call TriggerRegisterUnitStateEvent(udg_DmgEvTrig, u, UNIT_STATE_LIFE, GREATER_THAN, life)
        endif
    endif
    set u = null
    set f = null
    return false
endfunction
function CreateDmgEvTrg takes nothing returns nothing
    set udg_DamageEventTrigger = CreateTrigger()
    call TriggerAddCondition(udg_DamageEventTrigger, Filter(function OnUnitDamage))
endfunction
function GuhunEdit_RecreateTrigger takes nothing returns nothing
    local integer i = udg_UDexNext[0]
    
    set udg_DamageEventsWasted = 0
    
    //Rebuild the mass EVENT_UNIT_DAMAGED trigger:
    call DestroyTrigger(udg_DamageEventTrigger)
    call CreateDmgEvTrg()
    loop
        exitwhen i == 0
        if udg_UnitDamageRegistered[i] then
            call TriggerRegisterUnitEvent(udg_DamageEventTrigger, udg_UDexUnits[i], EVENT_UNIT_DAMAGED)
        endif
        set i = udg_UDexNext[i]
    endloop
    
    debug call BJDebugMsg("onDamage trigger rebuilt")
    call DestroyTimer(GetExpiredTimer())
endfunction
function SetupDmgEv takes nothing returns boolean
    local integer i = udg_UDex
    local unit u
    if udg_UnitIndexEvent == 1.00 then
        set u = udg_UDexUnits[i]
        if GetUnitAbilityLevel(u, 'Aloc') == 0 and TriggerEvaluate(gg_trg_Damage_Engine_Config) then
            set udg_UnitDamageRegistered[i] = true
            call TriggerRegisterUnitEvent(udg_DamageEventTrigger, u, EVENT_UNIT_DAMAGED)
            call UnitAddAbility(u, udg_SpellDamageAbility)
            call UnitMakeAbilityPermanent(u, true, udg_SpellDamageAbility)
        endif
        set u = null
    else
        set udg_HideDamageFrom[i] = false
        if udg_UnitDamageRegistered[i] then
            set udg_UnitDamageRegistered[i] = false
            set udg_DamageEventsWasted = udg_DamageEventsWasted + 1
            if udg_DamageEventsWasted == 32 then //After 32 registered units have been removed...
            
                // Rebuild onDamage trigger. But only once per game-frame (so mass-removals are less laggy)
                call TimerStart(CreateTimer(), 0, false, function GuhunEdit_RecreateTrigger)
            endif
        endif
    endif
    return false
endfunction
   
//===========================================================================
function InitTrig_Damage_Engine takes nothing returns nothing
    local unit u = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), 'uloc', 0, 0, 0)
    local integer i = bj_MAX_PLAYERS //Fixed in 3.8
   
    //Create this trigger with UnitIndexEvents in order add and remove units
    //as they are created or removed.
    local trigger t = CreateTrigger()
    call TriggerRegisterVariableEvent(t, "udg_UnitIndexEvent", EQUAL, 1.00)
    call TriggerRegisterVariableEvent(t, "udg_UnitIndexEvent", EQUAL, 2.00)
    call TriggerAddCondition(t, Filter(function SetupDmgEv))
    set t = null
   
    //Run the configuration trigger to set all configurables:
    if gg_trg_Damage_Engine_Config == null then
        //It's possible this InitTrig_ function ran first, in which case use ExecuteFunc.
        call ExecuteFunc("Trig_Damage_Engine_Config_Actions")
    else
        call TriggerExecute(gg_trg_Damage_Engine_Config)
    endif
   
    //Create trigger for storing all EVENT_UNIT_DAMAGED events.
    call CreateDmgEvTrg()
   
    //Create GUI-friendly trigger for cleaning up after UnitDamageTarget.
    set udg_ClearDamageEvent = CreateTrigger()
    call TriggerAddCondition(udg_ClearDamageEvent, Filter(function PreCheckDamagedLifeEvent))
   
    //Disable SpellDamageAbility for every player.
    loop
        set i = i - 1
        call SetPlayerAbilityAvailable(Player(i), udg_SpellDamageAbility, false)
        exitwhen i == 0
    endloop
   
    //Preload abilities.
    call UnitAddAbility(u, udg_DamageBlockingAbility)
    call UnitAddAbility(u, udg_SpellDamageAbility)
    call RemoveUnit(u)
    set u = null
endfunction