globals
    string array udg_AttackTypeDebugStr
    string array udg_DamageTypeDebugStr
    string array udg_WeaponTypeDebugStr
endglobals


//===========================================================================
//  
//  Damage Engine 5.4.2.3 - update requires copying of the JASS script
//  
//===========================================================================
library DamageEngine initializer Init
   
globals
    private timer   alarm       = CreateTimer()
    private boolean alarmSet    = false
   
    //Values to track the original pre-spirit Link/defensive damage values
    private boolean canKick         = true
    private boolean totem           = false
    private real lastAmount         = 0.00
    private real lastPrevAmt        = 0.00
    private integer lastType        = 0  
    private boolean lastCode        = false
    private real lastPierced        = 0.00
    private integer armorType       = 0
    private integer lastArmor       = 0
    private integer lastPrevArmor   = 0
    private integer defenseType     = 0
    private integer lastDefense     = 0
    private integer lastPrevDefense = 0
   
    //Stuff to track recursive UnitDamageTarget calls.
    private boolean eventsRun       = false
    private boolean kicking         = false
    private integer damageStack     = 0
    private unit array sourceStack
    private unit array targetStack
    private real array amountStack
    private attacktype array attackTStack
    private damagetype array damageTStack
    private weapontype array weaponTStack
    private integer array userTrigStack
    private integer array typeStack
   
    //Added in 5.4 to silently eliminate infinite recursion.
    private integer userTrigs = 9
    private integer eventTrig = 0
    private integer array nextTrig
    private trigger array userTrig
    private boolean array trigFrozen
       
    //Added/re-tooled in 5.4.1 to allow forced recursion (for advanced users only).
    private constant integer    LIMBO           = 16    //Recursion will never go deeper than LIMBO.
    private integer array       levelsDeep              //How deep the user recursion currently is.
    public boolean              inception       = false //You must set DamageEngine_inception = true before dealing damage to utlize this.
                                                        //When true, it allows your trigger to potentially go recursive up to LIMBO.
    private boolean             dreaming        = false
    private boolean array       inceptionTrig           //Added in 5.4.2 to simplify the inception variable for very complex DamageEvent trigger.
    private integer             sleepLevel      = 0
    private group               proclusGlobal   = CreateGroup() //track sources of recursion
    private group               fischerMorrow   = CreateGroup() //track targets of recursion
   
    //Improves readability in the code to have these as named constants.
    private constant integer    MOD_EVENT       = 1
    private constant integer    SHIELD_EVENT    = 4
    private constant integer    DAMAGE_EVENT    = 5
    private constant integer    ZERO_EVENT      = 6
    private constant integer    AFTER_EVENT     = 7
    private constant integer    LETHAL_EVENT    = 8
    private constant integer    AOE_EVENT       = 9
   
    //private string crashStr = ""
endglobals
   
//GUI Vars:
/*
    Retained from 3.8 and prior:
    ----------------------------
    unit            udg_DamageEventSource
    unit            udg_DamageEventTarget
    unit            udg_EnhancedDamageTarget
    group           udg_DamageEventAOEGroup
    integer         udg_DamageEventAOE
    integer         udg_DamageEventLevel
    real            udg_DamageModifierEvent
    real            udg_DamageEvent
    real            udg_AfterDamageEvent
    real            udg_DamageEventAmount
    real            udg_DamageEventPrevAmt
    real            udg_AOEDamageEvent
    boolean         udg_DamageEventOverride
    boolean         udg_NextDamageType
    boolean         udg_DamageEventType
    boolean         udg_IsDamageSpell
   
    //Added in 5.0:
    boolean          udg_IsDamageMelee    
    boolean          udg_IsDamageRanged    
    unit             udg_AOEDamageSource  
    real             udg_LethalDamageEvent
    real             udg_LethalDamageHP    
    real             udg_DamageScalingWC3
    integer          udg_DamageEventAttackT
    integer          udg_DamageEventDamageT
    integer          udg_DamageEventWeaponT
   
    //Added in 5.1:
    boolean          udg_IsDamageCode    
   
    //Added in 5.2:
    integer          udg_DamageEventArmorT  
    integer          udg_DamageEventDefenseT
   
    //Addded in 5.3:
    real             DamageEventArmorPierced
    real             udg_DamageScalingUser  
   
    //Added in 5.4.2 to allow GUI users to re-issue the exact same attack and damage type at the attacker.
    attacktype array udg_CONVERTED_ATTACK_TYPE
    damagetype array udg_CONVERTED_DAMAGE_TYPE
*/
   
    private function RunTrigs takes integer i returns nothing
        local integer cat = i
        if dreaming then
            //call BJDebugMsg("Tried to run triggers while triggers were already running.")
            return
        endif
        set dreaming = true
        //call BJDebugMsg("Start of event running")
        loop
            set i = nextTrig[i]
            exitwhen i == 0
            exitwhen cat == MOD_EVENT and (udg_DamageEventOverride or udg_DamageEventType*udg_DamageEventType == 4)
            exitwhen cat == SHIELD_EVENT and udg_DamageEventAmount <= 0.00
            exitwhen cat == LETHAL_EVENT and udg_LethalDamageHP > 0.405
            //set crashStr = "Bout to inspect " + I2S(i)
            if not trigFrozen[i] and IsTriggerEnabled(userTrig[i]) then
                set eventTrig = i
                //set crashStr = "Bout to evaluate " + I2S(i)
                if TriggerEvaluate(userTrig[i]) then
                    //set crashStr = "Bout to execute " + I2S(i)
                    call TriggerExecute(userTrig[i])
                endif
                //set crashStr = "Ran " + I2S(i)
                //call BJDebugMsg("Ran " + I2S(i))
                //if not (udg_DamageEventPrevAmt == 0.00 or udg_DamageScalingWC3 == 0.00 or udg_DamageEventAmount == 0.00) then
                //    if cat == MOD_EVENT then
                //        set udg_DamageScalingUser = udg_DamageEventAmount/udg_DamageEventPrevAmt
                //    elseif cat == SHIELD_EVENT then
                //        set udg_DamageScalingUser = udg_DamageEventAmount/udg_DamageEventPrevAmt/udg_DamageScalingWC3
                //    endif
                //elseif udg_DamageEventPrevAmt == 0.00 then
                //    call BJDebugMsg("Prev amount 0.00 and User Amount " + R2S(udg_DamageEventAmount))
                //elseif udg_DamageEventAmount == 0.00 then
                //    call BJDebugMsg("User amount 0.00 and Prev Amount " + R2S(udg_DamageEventPrevAmt))
                //elseif udg_DamageScalingWC3 == 0.00 then
                //    call BJDebugMsg("WC3 amount somehow 0.00")
                //endif
                //set crashStr = "Filtered " + I2S(i)
            //elseif i > 9 then
            //    if trigFrozen[i] then
            //        call BJDebugMsg("User Trigger is frozen")
            //    else
            //        call BJDebugMsg("User Trigger is off")
            //    endif
            endif
        endloop
        //call BJDebugMsg("End of event running")
        set dreaming = false
    endfunction
   
    private function OnAOEEnd takes nothing returns nothing
        if udg_DamageEventAOE > 1 then
            call RunTrigs(AOE_EVENT)
            set udg_DamageEventAOE      = 1
        endif
        set udg_DamageEventLevel        = 1
        set udg_EnhancedDamageTarget    = null
        set udg_AOEDamageSource         = null
        call GroupClear(udg_DamageEventAOEGroup)
    endfunction
   
    private function AfterDamage takes nothing returns nothing
        if udg_DamageEventPrevAmt != 0.00 and udg_DamageEventDamageT != udg_DAMAGE_TYPE_UNKNOWN then
            call RunTrigs(AFTER_EVENT)
        endif
    endfunction
   
    private function Finish takes nothing returns nothing
        local integer i = 0
        local integer exit
        if eventsRun then
            //call BJDebugMsg("events ran")
            set eventsRun = false
            call AfterDamage()
        endif
        if canKick and not kicking then
            //call BJDebugMsg("can kick")
            if damageStack > 0 then
                set kicking = true
                //call BJDebugMsg("Clearing queued damage instances: " + I2S(damageStack))
                loop
                    set exit = damageStack
                    set sleepLevel = sleepLevel + 1
                    loop
                        set udg_NextDamageType = typeStack[i]
                        //call BJDebugMsg("Stacking on " + R2S(amountStack[i]))
                        call UnitDamageTarget(sourceStack[i], targetStack[i], amountStack[i], true, false, attackTStack[i], damageTStack[i], weaponTStack[i])
                        call AfterDamage()
                        set i = i + 1 //Need to loop bottom to top to make sure damage order is preserved.
                        exitwhen i == exit
                    endloop
                    //call BJDebugMsg("Exit at: " + I2S(i))
                    exitwhen i == damageStack
                endloop
                //call BJDebugMsg("Terminate at at: " + I2S(i))
                set sleepLevel = 0
                loop
                    set i = i - 1
                    set trigFrozen[userTrigStack[i]] = false //Only re-enable recursive triggers AFTER all damage is dealt.
                    set levelsDeep[userTrigStack[i]] = 0 //Reset this stuff if the user tried some nonsense
                    exitwhen i == 0
                endloop
                //call BJDebugMsg("Cleared queued damage instances: " + I2S(damageStack))
                set damageStack = 0 //Can only be set after all the damage has successfully ended.
                set kicking = false
            endif
            call GroupClear(proclusGlobal)
            call GroupClear(fischerMorrow)
        //elseif kicking then
        //    call BJDebugMsg("Somehow still kicking")
        //else
        //    call BJDebugMsg("Cannot kick")
        endif
    endfunction
   
    private function ResetArmor takes nothing returns nothing
        if udg_DamageEventArmorPierced != 0.00 then
            call BlzSetUnitArmor(udg_DamageEventTarget, BlzGetUnitArmor(udg_DamageEventTarget) + udg_DamageEventArmorPierced)
        endif
        if armorType != udg_DamageEventArmorT then
            call BlzSetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_ARMOR_TYPE, armorType) //revert changes made to the damage instance
        endif
        if defenseType != udg_DamageEventDefenseT then
            call BlzSetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_DEFENSE_TYPE, defenseType)
        endif
    endfunction
   
    private function FailsafeClear takes nothing returns nothing
        //call BJDebugMsg("Damage from " + GetUnitName(udg_DamageEventSource) + " to " + GetUnitName(udg_DamageEventTarget) + " has been messing up Damage Engine.")
        //call BJDebugMsg(R2S(udg_DamageEventAmount) + " " + " " + R2S(udg_DamageEventPrevAmt) + " " + udg_AttackTypeDebugStr[udg_DamageEventAttackT] + " " + udg_DamageTypeDebugStr[udg_DamageEventDamageT])
        call ResetArmor()
        set canKick = true
        set totem = false
        set udg_DamageEventAmount = 0.00
        set udg_DamageScalingWC3  = 0.00
        if udg_DamageEventDamageT != udg_DAMAGE_TYPE_UNKNOWN then
            call RunTrigs(DAMAGE_EVENT) //Run the normal on-damage event based on this failure.
            set eventsRun = true //Run the normal after-damage event based on this failure.
        endif
        call Finish()
    endfunction
   
    private function WakeUp takes nothing returns nothing
        set alarmSet    = false //The timer has expired. Flag off to allow it to be restarted when needed.
        //if dreaming then
        //    set dreaming= false
        //    call BJDebugMsg("Timer set dreaming to False")
        //    call BJDebugMsg(crashStr)
        //endif
        if totem then
            //Something went wrong somewhere; the WarCraft 3 engine didn't run the DAMAGED event despite running the DAMAGING event.
            call FailsafeClear()
        else
            if not canKick and damageStack > 0 then
                //call BJDebugMsg("Damage Engine recursion deployment was failing with application of: " + R2S(udg_DamageEventAmount))
                set canKick = true
            endif
            call Finish() //Wrap up any outstanding damage instance
        endif
        call OnAOEEnd() //Reset things so they don't perpetuate for AoE/Level target detection
        set udg_DamageEventPrevAmt = 0.00 //Added in 5.4.2.1 to try to squash the Cold Arrows glitch (failed to do it)
    endfunction
   
    private function CalibrateMR takes nothing returns nothing
        set udg_IsDamageMelee           = false
        set udg_IsDamageRanged          = false
        set udg_IsDamageSpell           = udg_DamageEventAttackT == 0 //In Patch 1.31, one can just check the attack type to find out if it's a spell.
        if udg_DamageEventDamageT == udg_DAMAGE_TYPE_NORMAL and not udg_IsDamageSpell then //This damage type is the only one that can get reduced by armor.
            set udg_IsDamageMelee       = IsUnitType(udg_DamageEventSource, UNIT_TYPE_MELEE_ATTACKER)
            set udg_IsDamageRanged      = IsUnitType(udg_DamageEventSource, UNIT_TYPE_RANGED_ATTACKER)
            if udg_IsDamageMelee and udg_IsDamageRanged then
                set udg_IsDamageMelee   = udg_DamageEventWeaponT > 0// Melee units play a sound when damaging
                set udg_IsDamageRanged  = not udg_IsDamageMelee     // In the case where a unit is both ranged and melee, the ranged attack plays no sound.
            endif                                                   // The Huntress has a melee sound for her ranged projectile, however it is only an issue
        endif                                                       //if she also had a melee attack, because by default she is only UNIT_TYPE_RANGED_ATTACKER.
    endfunction
   
    private function OnPreDamage takes nothing returns boolean
        local unit src      = GetEventDamageSource()
        local unit tgt      = GetTriggerUnit()
        local real amt      = GetEventDamage()
        local attacktype at = BlzGetEventAttackType()
        local damagetype dt = BlzGetEventDamageType()
        local weapontype wt = BlzGetEventWeaponType()
       
        //call BJDebugMsg("First damage event running")
       
        if dreaming then
            //call BJDebugMsg("Dreaming")
            if amt != 0.00 then
                //Store recursive damage into a queue from index "damageStack" (0-15)
                //This damage will be fired after the current damage instance has wrapped up its events.
                //This damage can only be caused by triggers.
                set amountStack[damageStack]   = amt
                set sourceStack[damageStack]   = src
                set targetStack[damageStack]   = tgt
                set attackTStack[damageStack]  = at
                set damageTStack[damageStack]  = dt
                set weaponTStack[damageStack]  = wt
                set userTrigStack[damageStack] = eventTrig
                if udg_NextDamageType == 0 then
                    set typeStack[damageStack] = udg_DamageTypeCode
                else
                    set typeStack[damageStack] = udg_NextDamageType
                endif
                //Next block added in 5.4.1 to allow *some* control over whether recursion should kick
                //in. Also it's important to track whether the source and target were both involved at
                //some earlier point, so this is a more accurate and lenient method than before.
                set inception = inception or inceptionTrig[eventTrig]
                call GroupAddUnit(proclusGlobal, udg_DamageEventSource)
                call GroupAddUnit(fischerMorrow, udg_DamageEventTarget)
                if kicking and IsUnitInGroup(src, proclusGlobal) and IsUnitInGroup(tgt, fischerMorrow) then
                    if inception and not trigFrozen[eventTrig] then
                        set inceptionTrig[eventTrig] = true
                        if levelsDeep[eventTrig] < sleepLevel then
                            set levelsDeep[eventTrig] = levelsDeep[eventTrig] + 1
                            if levelsDeep[eventTrig] >= LIMBO then
                                set trigFrozen[eventTrig] = true
                            endif
                        endif
                    else
                        set trigFrozen[eventTrig] = true
                    endif
                endif
                set damageStack = damageStack + 1
                //call BJDebugMsg("damageStack: " + I2S(damageStack) + " levelsDeep: " + I2S(levelsDeep[eventTrig]) + " sleepLevel: " + I2S(sleepLevel))
                call BlzSetEventDamage(0.00) //queue the damage instance instead of letting it run recursively
            endif
        else
            if not kicking then
                //Added 25 July 2017 to detect AOE damage or multiple single-target damage
                if alarmSet then
                    if totem then
                        if dt != DAMAGE_TYPE_SPIRIT_LINK and dt != DAMAGE_TYPE_DEFENSIVE and dt != DAMAGE_TYPE_PLANT then
                            //if 'totem' is still set and it's not due to spirit link distribution or defense retaliation,
                            //the next function must be called as a debug. This reverts an issue I created in patch 5.1.3.
                            call FailsafeClear()
                        else
                            set totem           = false
                            set lastAmount      = udg_DamageEventAmount
                            set lastPrevAmt     = udg_DamageEventPrevAmt    //Store the actual pre-armor value.
                            set lastType        = udg_DamageEventType       //also store the damage type.
                            set lastCode        = udg_IsDamageCode          //store this as well.
                            set lastArmor       = udg_DamageEventArmorT
                            set lastPrevArmor   = armorType
                            set lastDefense     = udg_DamageEventDefenseT
                            set lastPrevDefense = defenseType
                            set lastPierced     = udg_DamageEventArmorPierced
                            set canKick         = false
                        endif
                    else
                        call Finish()
                    endif
                    if src != udg_AOEDamageSource then //Source has damaged more than once
                        call OnAOEEnd() //New damage source - unflag everything
                        set udg_AOEDamageSource = src
                    elseif tgt == udg_EnhancedDamageTarget then
                        set udg_DamageEventLevel= udg_DamageEventLevel + 1  //The number of times the same unit was hit.
                    elseif not IsUnitInGroup(tgt, udg_DamageEventAOEGroup) then
                        set udg_DamageEventAOE  = udg_DamageEventAOE + 1    //Multiple targets hit by this source - flag as AOE
                    endif
                else
                    call TimerStart(alarm, 0.00, false, function WakeUp)
                    set alarmSet                = true
                    set udg_AOEDamageSource     = src
                    set udg_EnhancedDamageTarget= tgt
                endif
                call GroupAddUnit(udg_DamageEventAOEGroup, tgt)
            endif
            set udg_DamageEventType             = udg_NextDamageType
            set udg_IsDamageCode                = udg_NextDamageType != 0
            set udg_DamageEventOverride         = dt == null //Got rid of NextDamageOverride in 5.1 for simplicity
            set udg_DamageEventPrevAmt          = amt
            set udg_DamageEventSource           = src
            set udg_DamageEventTarget           = tgt
            set udg_DamageEventAmount           = amt
            set udg_DamageEventAttackT          = GetHandleId(at)
            set udg_DamageEventDamageT          = GetHandleId(dt)
            set udg_DamageEventWeaponT          = GetHandleId(wt)
           
            call CalibrateMR() //Set Melee and Ranged settings.
           
            set udg_DamageEventArmorT           = BlzGetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_ARMOR_TYPE) //Introduced in Damage Engine 5.2.0.0
            set udg_DamageEventDefenseT         = BlzGetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_DEFENSE_TYPE)
            set armorType                       = udg_DamageEventArmorT
            set defenseType                     = udg_DamageEventDefenseT
            set udg_DamageEventArmorPierced     = 0.00
            set udg_DamageScalingUser           = 1.00
            set udg_DamageScalingWC3            = 1.00
           
            if amt != 0.00 then
                if not udg_DamageEventOverride then
                    call RunTrigs(MOD_EVENT)
               
                    //All events have run and the pre-damage amount is finalized.
                    call BlzSetEventAttackType(ConvertAttackType(udg_DamageEventAttackT))
                    call BlzSetEventDamageType(ConvertDamageType(udg_DamageEventDamageT))
                    call BlzSetEventWeaponType(ConvertWeaponType(udg_DamageEventWeaponT))
                    if udg_DamageEventArmorPierced != 0.00 then
                        call BlzSetUnitArmor(udg_DamageEventTarget, BlzGetUnitArmor(udg_DamageEventTarget) - udg_DamageEventArmorPierced)
                    endif
                    if armorType != udg_DamageEventArmorT then
                        call BlzSetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_ARMOR_TYPE, udg_DamageEventArmorT) //Introduced in Damage Engine 5.2.0.0
                    endif
                    if defenseType != udg_DamageEventDefenseT then
                        call BlzSetUnitIntegerField(udg_DamageEventTarget, UNIT_IF_DEFENSE_TYPE, udg_DamageEventDefenseT) //Introduced in Damage Engine 5.2.0.0
                    endif
                    call BlzSetEventDamage(udg_DamageEventAmount)
                endif
                //call BJDebugMsg("Ready to deal " + R2S(udg_DamageEventAmount))
                set totem = true
            else
                call RunTrigs(ZERO_EVENT)
                set canKick = true
                call Finish()
            endif
        endif
        set src = null
        set tgt = null
        set inception = false
        set udg_NextDamageType = 0
        return false
    endfunction
   
    //The traditional on-damage response, where armor reduction has already been factored in.
    private function OnDamage takes nothing returns boolean
        local real r = GetEventDamage()
        //call BJDebugMsg("Second damage event running")
        if dreaming or udg_DamageEventPrevAmt == 0.00 then
            //if dreaming then
            //    call BJDebugMsg("Dreaming")
            //else
            //    call BJDebugMsg("Prev amount is zero")
            //endif
            return false
        endif
        if totem then
            set totem = false   //This should be the case in almost all circumstances
        else
            call AfterDamage() //Wrap up the outstanding damage instance
            set canKick                     = true
            //Unfortunately, Spirit Link and Thorns Aura/Spiked Carapace fire the DAMAGED event out of sequence with the DAMAGING event,
            //so I have to re-generate a buncha stuff here.
            set udg_DamageEventSource       = GetEventDamageSource()
            set udg_DamageEventTarget       = GetTriggerUnit()
            set udg_DamageEventAmount       = lastAmount
            set udg_DamageEventPrevAmt      = lastPrevAmt
            set udg_DamageEventAttackT      = GetHandleId(BlzGetEventAttackType())
            set udg_DamageEventDamageT      = GetHandleId(BlzGetEventDamageType())
            set udg_DamageEventWeaponT      = GetHandleId(BlzGetEventWeaponType())
            set udg_DamageEventType         = lastType
            set udg_IsDamageCode            = lastCode
            set udg_DamageEventArmorT       = lastArmor
            set udg_DamageEventDefenseT     = lastDefense
            set udg_DamageEventArmorPierced = lastPierced
            set armorType                   = lastPrevArmor
            set defenseType                 = lastPrevDefense
            call CalibrateMR() //Apply melee/ranged settings once again.
        endif
        call ResetArmor()
        if udg_DamageEventAmount != 0.00 and r != 0.00 then
            set udg_DamageScalingWC3 = r / udg_DamageEventAmount
        elseif udg_DamageEventAmount > 0.00 then
            set udg_DamageScalingWC3 = 0.00
        else
            set udg_DamageScalingWC3 = 1.00
            set udg_DamageScalingUser = udg_DamageEventAmount / udg_DamageEventPrevAmt
        endif
        set udg_DamageEventAmount = udg_DamageEventAmount*udg_DamageScalingWC3
       
        if udg_DamageEventAmount > 0.00 then
            //This event is used for custom shields which have a limited hit point value
            //The shield here kicks in after armor, so it acts like extra hit points.
            call RunTrigs(SHIELD_EVENT)
            set udg_LethalDamageHP = GetWidgetLife(udg_DamageEventTarget) - udg_DamageEventAmount
            if udg_LethalDamageHP <= 0.405 then
                call RunTrigs(LETHAL_EVENT) //Added 10 May 2019 to detect and potentially prevent lethal damage. Instead of
                //modifying the damage, you need to modify LethalDamageHP instead (the final HP of the unit).
               
                set udg_DamageEventAmount = GetWidgetLife(udg_DamageEventTarget) - udg_LethalDamageHP
                if udg_DamageEventType < 0 and udg_LethalDamageHP <= 0.405 then
                    call SetUnitExploded(udg_DamageEventTarget, true)   //Explosive damage types should blow up the target.
                endif
            endif
            set udg_DamageScalingUser = udg_DamageEventAmount/udg_DamageEventPrevAmt/udg_DamageScalingWC3
        endif
        call BlzSetEventDamage(udg_DamageEventAmount)   //Apply the final damage amount.
        if udg_DamageEventDamageT != udg_DAMAGE_TYPE_UNKNOWN then
            call RunTrigs(DAMAGE_EVENT)
        endif
        set eventsRun = true
        if udg_DamageEventAmount == 0.00 then
            call Finish()
        endif
        return false
    endfunction
   
    //===========================================================================
    private function Init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DAMAGED) //Thanks to this I no longer have to create an event for every unit in the map.
        call TriggerAddCondition(trig, Filter(function OnDamage))
        set trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DAMAGING) //The new 1.31 event which fires before damage.
        call TriggerAddCondition(trig, Filter(function OnPreDamage))
        
        // Added by Guhun to work around W3X2LNI renaming vars when it shouldn't
        call TriggerRegisterVariableEvent(null, "udg_DamageModifierEvent", null, 0.)
        call TriggerRegisterVariableEvent(null, "udg_DamageEvent", null, 0.)
        call TriggerRegisterVariableEvent(null, "udg_AfterDamageEvent", null, 0.)
        call TriggerRegisterVariableEvent(null, "udg_LethalDamageEvent", null, 0.)
        call TriggerRegisterVariableEvent(null, "udg_AOEDamageEvent", null, 0.)
        set trig = null
    endfunction
   
    public function DebugStr takes nothing returns nothing
        local integer i = 0
        loop
            set udg_CONVERTED_ATTACK_TYPE[i] = ConvertAttackType(i)
            exitwhen i == 6
            set i = i + 1
        endloop
        set i = 0
        loop
            set udg_CONVERTED_DAMAGE_TYPE[i] = ConvertDamageType(i)
            exitwhen i == 26
            set i = i + 1
        endloop
        set udg_AttackTypeDebugStr[0] = "SPELLS"    //ATTACK_TYPE_NORMAL in JASS
        set udg_AttackTypeDebugStr[1] = "NORMAL"    //ATTACK_TYPE_MELEE in JASS
        set udg_AttackTypeDebugStr[2] = "PIERCE"
        set udg_AttackTypeDebugStr[3] = "SIEGE"
        set udg_AttackTypeDebugStr[4] = "MAGIC"
        set udg_AttackTypeDebugStr[5] = "CHAOS"
        set udg_AttackTypeDebugStr[6] = "HERO"
       
        set udg_DamageTypeDebugStr[0]  = "UNKNOWN"
        set udg_DamageTypeDebugStr[4]  = "NORMAL"
        set udg_DamageTypeDebugStr[5]  = "ENHANCED"
        set udg_DamageTypeDebugStr[8]  = "FIRE"
        set udg_DamageTypeDebugStr[9]  = "COLD"
        set udg_DamageTypeDebugStr[10] = "LIGHTNING"
        set udg_DamageTypeDebugStr[11] = "POISON"
        set udg_DamageTypeDebugStr[12] = "DISEASE"
        set udg_DamageTypeDebugStr[13] = "DIVINE"
        set udg_DamageTypeDebugStr[14] = "MAGIC"
        set udg_DamageTypeDebugStr[15] = "SONIC"
        set udg_DamageTypeDebugStr[16] = "ACID"
        set udg_DamageTypeDebugStr[17] = "FORCE"
        set udg_DamageTypeDebugStr[18] = "DEATH"
        set udg_DamageTypeDebugStr[19] = "MIND"
        set udg_DamageTypeDebugStr[20] = "PLANT"
        set udg_DamageTypeDebugStr[21] = "DEFENSIVE"
        set udg_DamageTypeDebugStr[22] = "DEMOLITION"
        set udg_DamageTypeDebugStr[23] = "SLOW_POISON"
        set udg_DamageTypeDebugStr[24] = "SPIRIT_LINK"
        set udg_DamageTypeDebugStr[25] = "SHADOW_STRIKE"
        set udg_DamageTypeDebugStr[26] = "UNIVERSAL"
        set udg_WeaponTypeDebugStr[0]  = "NONE"     //WEAPON_TYPE_WHOKNOWS in JASS
        set udg_WeaponTypeDebugStr[1]  = "METAL_LIGHT_CHOP"
        set udg_WeaponTypeDebugStr[2]  = "METAL_MEDIUM_CHOP"
        set udg_WeaponTypeDebugStr[3]  = "METAL_HEAVY_CHOP"
        set udg_WeaponTypeDebugStr[4]  = "METAL_LIGHT_SLICE"
        set udg_WeaponTypeDebugStr[5]  = "METAL_MEDIUM_SLICE"
        set udg_WeaponTypeDebugStr[6]  = "METAL_HEAVY_SLICE"
        set udg_WeaponTypeDebugStr[7]  = "METAL_MEDIUM_BASH"
        set udg_WeaponTypeDebugStr[8]  = "METAL_HEAVY_BASH"
        set udg_WeaponTypeDebugStr[9]  = "METAL_MEDIUM_STAB"
        set udg_WeaponTypeDebugStr[10] = "METAL_HEAVY_STAB"
        set udg_WeaponTypeDebugStr[11] = "WOOD_LIGHT_SLICE"
        set udg_WeaponTypeDebugStr[12] = "WOOD_MEDIUM_SLICE"
        set udg_WeaponTypeDebugStr[13] = "WOOD_HEAVY_SLICE"
        set udg_WeaponTypeDebugStr[14] = "WOOD_LIGHT_BASH"
        set udg_WeaponTypeDebugStr[15] = "WOOD_MEDIUM_BASH"
        set udg_WeaponTypeDebugStr[16] = "WOOD_HEAVY_BASH"
        set udg_WeaponTypeDebugStr[17] = "WOOD_LIGHT_STAB"
        set udg_WeaponTypeDebugStr[18] = "WOOD_MEDIUM_STAB"
        set udg_WeaponTypeDebugStr[19] = "CLAW_LIGHT_SLICE"
        set udg_WeaponTypeDebugStr[20] = "CLAW_MEDIUM_SLICE"
        set udg_WeaponTypeDebugStr[21] = "CLAW_HEAVY_SLICE"
        set udg_WeaponTypeDebugStr[22] = "AXE_MEDIUM_CHOP"
        set udg_WeaponTypeDebugStr[23] = "ROCK_HEAVY_BASH"
        set udg_DefenseTypeDebugStr[0] = "LIGHT"
        set udg_DefenseTypeDebugStr[1] = "MEDIUM"
        set udg_DefenseTypeDebugStr[2] = "HEAVY"
        set udg_DefenseTypeDebugStr[3] = "FORTIFIED"
        set udg_DefenseTypeDebugStr[4] = "NORMAL"   //Typically deals flat damage to all armor types
        set udg_DefenseTypeDebugStr[5] = "HERO"
        set udg_DefenseTypeDebugStr[6] = "DIVINE"
        set udg_DefenseTypeDebugStr[7] = "UNARMORED"
       
        set udg_ArmorTypeDebugStr[0] = "NONE"       //ARMOR_TYPE_WHOKNOWS in JASS, added in 1.31
        set udg_ArmorTypeDebugStr[1] = "FLESH"
        set udg_ArmorTypeDebugStr[2] = "METAL"
        set udg_ArmorTypeDebugStr[3] = "WOOD"
        set udg_ArmorTypeDebugStr[4] = "ETHEREAL"
        set udg_ArmorTypeDebugStr[5] = "STONE"
    endfunction
   
    //This function exists mainly to make it easier to switch from another DDS, like PDD.
    function UnitDamageTargetEx takes unit src, unit tgt, real amt, boolean a, boolean r, attacktype at, damagetype dt, weapontype wt returns boolean
        if udg_NextDamageType == 0 then
           set udg_NextDamageType = udg_DamageTypeCode
        endif
        call UnitDamageTarget(src, tgt, amt, a, r, at, dt, wt)
        return dreaming
    endfunction
   
    public function SetupEvent takes trigger whichTrig, string var, integer index returns nothing
        local integer max = 1
        local integer off = 0
        local integer exit = 0
        local integer i
        if var == "udg_DamageModifierEvent" then //MOD_EVENT 1-4 -> Events 1-4
            if index < 3 then
                set exit = index + 1
            endif
            if nextTrig[1] == 0 then
                set nextTrig[1] = 2
                set nextTrig[2] = 3
                set trigFrozen[2] = true
                set trigFrozen[3] = true
            endif
            set max = 4
        elseif var == "udg_DamageEvent" then //DAMAGE_EVENT 1,2 -> Events 5,6
            set max = 2
            set off = 4
        elseif var == "udg_AfterDamageEvent" then //AFTER_EVENT -> Event 7
            set off = 6
        elseif var == "udg_LethalDamageEvent" then //LETHAL_EVENT -> Event 8
            set off = 7
        elseif var == "udg_AOEDamageEvent" then //AOE_EVENT -> Event 9
            set off = 8
        else
            return
        endif
        set i = IMaxBJ(IMinBJ(index, max), 1) + off
        //call BJDebugMsg("Root index: " + I2S(i))
        loop
            set index = i
            set i = nextTrig[i]
            exitwhen i == exit
        endloop
        set userTrigs = userTrigs + 1   //User list runs from index 10 and up
        set nextTrig[index] = userTrigs
        set nextTrig[userTrigs] = exit
        set userTrig[userTrigs] = whichTrig
        //call BJDebugMsg("Registered " + I2S(userTrigs) + " to " + I2S(index))
    endfunction
   
    // private function PreSetup takes trigger whichTrig, string var, limitop op, real value returns nothing
        // call SetupEvent(whichTrig, var, R2I(value))
    // endfunction
   
    // hook TriggerRegisterVariableEvent PreSetup
   
endlibrary
 