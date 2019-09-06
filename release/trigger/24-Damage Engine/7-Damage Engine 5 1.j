globals
    string array udg_AttackTypeDebugStr
    string array udg_DamageTypeDebugStr
    string array udg_WeaponTypeDebugStr
endglobals
//===========================================================================
// Damage Engine lets you detect, amplify, block or nullify damage. It even
// lets you detect if the damage was physical or from a spell. Just reference
// DamageEventAmount/Source/Target or the boolean IsDamageSpell, to get the
// necessary damage event data.
//
// - Detect damage (after it's been dealt to the unit): use the event "DamageEvent Equal to 1.00"
// - To change damage before it's dealt: use the event "DamageModifierEvent Equal to 1.00"
// - Detect spell damage: use the condition "IsDamageSpell Equal to True"
// - Detect zero-damage: use the event "DamageEvent Equal to 2.00"
//
// You can specify the DamageEventType before dealing triggered damage:
// - Set NextDamageType = DamageTypeWhatever
// - Unit - Cause...
//
// You can modify the DamageEventAmount and the DamageEventType from a "DamageModifierEvent Equal to 1.00" trigger.
// - If the amount is modified to negative, it will count as a heal.
// - If the amount is set to 0, no damage will be dealt.
//
// If you need to reference the original in-game damage, use the variable "DamageEventPrevAmt".
//
//===========================================================================
library DamageEngine initializer Init

globals
    private boolean started = false
    private integer recursion = -1
    private boolean recursive = false
    private boolean purge = false
    private timer ticker = CreateTimer()
    private trigger trig = CreateTrigger()
    
    private real previousAmount = 0.00      //Added to track the original modified damage pre-spirit Link
    private real previousValue = 0.00       //Added to track the original pure damage amount of Spirit Link
    private integer previousType = 0        //Track the type
    private boolean previousCode = false    //Was it caused by a trigger/script?
    private boolean preDamage = false
    private boolean holdClear = false
    
    private unit array lastSource    
    private unit array lastTarget    
    private real array lastAmount    
    private attacktype array lastAttackT    
    private damagetype array lastDamageT    
    private weapontype array lastWeaponT    
    private trigger array lastTrig    
    private integer array lastType    
endglobals

//GUI Vars:
/*
    trigger udg_DamageEventTrigger      //Different functionality from before in 5.1
    
    boolean udg_DamageEventOverride
    boolean udg_NextDamageType
    boolean udg_DamageEventType
    boolean udg_IsDamageCode            //New in 5.1 as per request from chopinski
    boolean udg_IsDamageSpell
    boolean udg_IsDamageMelee           //New in 5.0
    boolean udg_IsDamageRanged          //New in 5.0
    
    unit udg_DamageEventSource
    unit udg_DamageEventTarget
    
    real    udg_AOEDamageEvent
    integer udg_DamageEventAOE
    group   udg_DamageEventAOEGroup
    unit    udg_AOEDamageSource         //New in 5.0
    integer udg_DamageEventLevel
    unit    udg_EnhancedDamageTarget
    
    real udg_DamageEvent
    real udg_DamageModifierEvent
    real udg_LethalDamageEvent          //New in 5.0
    
    real udg_DamageEventAmount
    real udg_DamageEventPrevAmt
    real udg_LethalDamageHP             //New in 5.0
    
    integer udg_DamageEventAttackT      //New in 5.0
    integer udg_DamageEventDamageT      //New in 5.0
    integer udg_DamageEventWeaponT      //New in 5.0
*/

private function Error takes nothing returns nothing
    local string s = "WARNING: Recursion error when dealing damage! Prior to dealing damage from within a DamageEvent response trigger, do this:\n"
    set s = s + "Set DamageEventTrigger = (This Trigger)\n"
    set s = s + "Unit - Cause <Source> to damage <Target>...\n\n"
    set s = s + "Alternatively, just use the UNKNOWN damage type. It will skip recursive damage on its own without needing the \"Set\" line:\n"
    set s = s + "Unit - Cause <Source> to damage <Target>, dealing <Amount> damage of attack type <Attack Type> and damage type Unknown"
    
    call ClearTextMessages()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 999.00, s)
endfunction

private function OnAOEEnd takes nothing returns nothing
    if udg_DamageEventAOE > 1 then
        set udg_AOEDamageEvent      = 0.00
        set udg_AOEDamageEvent      = 1.00
        set udg_DamageEventAOE      = 1
    endif
    set udg_DamageEventLevel        = 1
    set udg_EnhancedDamageTarget    = null
    set udg_AOEDamageSource         = null
    call GroupClear(udg_DamageEventAOEGroup)
endfunction
    
private function OnExpire takes nothing returns nothing
    set started = false //The timer has expired. Flag off to allow it to be restarted when needed.
    
    call OnAOEEnd() //Reset things so they don't perpetuate for AoE/Level target detection
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

//Load the event responses into the Pre-Damage Modification trigger.
private function OnPreDamage takes nothing returns boolean
    local unit src      = GetEventDamageSource()
    local unit tgt      = BlzGetEventDamageTarget()
    local real amt      = GetEventDamage()
    local attacktype at = BlzGetEventAttackType()
    local damagetype dt = BlzGetEventDamageType()
    local weapontype wt = BlzGetEventWeaponType()
    
    if udg_NextDamageType == 0 and (udg_DamageEventTrigger != null or recursive) then
        set udg_NextDamageType      = udg_DamageTypeCode
    endif
    if recursive then
        if amt != 0.00 then
            if recursion < 16 then  //when 16 events are run recursively from one damage instance, it's a safe bet that something has gone wrong.
                set recursion = recursion + 1
                
                //Store recursive damage into a queue from index "recursion" (0-15)
                //This damage will be fired after the current damage instance has wrapped up its events.
                //This damage can only be caused by triggers.
                set lastAmount[recursion]   = amt
                set lastSource[recursion]   = src
                set lastTarget[recursion]   = tgt
                set lastAttackT[recursion]  = at
                set lastDamageT[recursion]  = dt
                set lastWeaponT[recursion]  = wt                
                set lastTrig[recursion]     = udg_DamageEventTrigger
                set lastType[recursion]     = udg_NextDamageType
            else
                //Delete or comment-out the next line to disable the in-game recursion crash warning
                call Error()
            endif
        endif
        set udg_NextDamageType          = 0
        set udg_DamageEventTrigger      = null
        call BlzSetEventDamage(0.00) //queue the damage instance instead of letting it run recursively
    else
        if not purge then
            //Added 25 July 2017 to detect AOE damage or multiple single-target damage
            if started then
                if src != udg_AOEDamageSource then //Source has damaged more than once
                    
                    call OnAOEEnd() //New damage source - unflag everything
                    set udg_AOEDamageSource = src
                elseif tgt == udg_EnhancedDamageTarget then
                    set udg_DamageEventLevel= udg_DamageEventLevel + 1  //The number of times the same unit was hit.
                elseif not IsUnitInGroup(tgt, udg_DamageEventAOEGroup) then
                    set udg_DamageEventAOE  = udg_DamageEventAOE + 1    //Multiple targets hit by this source - flag as AOE
                endif
                if preDamage then
                    set preDamage           = false
                    set previousAmount      = udg_DamageEventAmount
                    set previousValue       = udg_DamageEventPrevAmt    //Store the actual pre-armor value.
                    set previousType        = udg_DamageEventType       //also store the damage type.
                    set previousCode        = udg_IsDamageCode          //store this as well.
                    set holdClear           = true
                endif
            else
                call TimerStart(ticker, 0.00, false, function OnExpire)
                set started                 = true
                set udg_AOEDamageSource     = src
                set udg_EnhancedDamageTarget= tgt
            endif
            call GroupAddUnit(udg_DamageEventAOEGroup, tgt)
        endif
        
        set udg_DamageEventType             = udg_NextDamageType
        if udg_NextDamageType != 0 then 
            set udg_DamageEventType         = udg_NextDamageType
            set udg_NextDamageType          = 0
            set udg_IsDamageCode            = true //New in 5.1 - requested by chopinski to allow user to detect Code damage
                
            set udg_DamageEventTrigger      = null
        endif   
        set udg_DamageEventOverride         = dt == null or amt == 0.00 or udg_DamageEventType*udg_DamageEventType == 4 //Got rid of NextDamageOverride in 5.1 for simplicity
        set udg_DamageEventPrevAmt          = amt
        
        set udg_DamageEventSource           = src    
        set udg_DamageEventTarget           = tgt        
        set udg_DamageEventAmount           = amt
        set udg_DamageEventAttackT          = GetHandleId(at)
        set udg_DamageEventDamageT          = GetHandleId(dt)
        set udg_DamageEventWeaponT          = GetHandleId(wt)
        
        call CalibrateMR() //Set Melee and Ranged settings.
        
        //Ignores event on various debuffs like Faerie Fire - alternatively,
        //the user can exploit UNKNOWN damage type to avoid damage detection.
        if not udg_DamageEventOverride then
            set recursive = true
            
            set udg_DamageModifierEvent = 0.00
            set udg_DamageModifierEvent = 1.00  //I recommend using this for changing damage types or for when you need to do things that should override subsequent damage modification.
            
            set udg_DamageEventOverride = udg_DamageEventOverride or udg_DamageEventType*udg_DamageEventType == 4
            if not udg_DamageEventOverride then
                set udg_DamageModifierEvent = 2.00  //This should involve damage calculation based on multiplication/percentages.
                set udg_DamageModifierEvent = 3.00  //This should just be addition or subtraction at this point.
            endif
            
            set recursive = false
        endif
        
        //All events have run and the pre-damage amount is finalized.
        call BlzSetEventAttackType(ConvertAttackType(udg_DamageEventAttackT))
        call BlzSetEventDamageType(ConvertDamageType(udg_DamageEventDamageT))
        call BlzSetEventWeaponType(ConvertWeaponType(udg_DamageEventWeaponT))
        call BlzSetEventDamage(udg_DamageEventAmount)
        set preDamage = true
        //call BJDebugMsg("Ready to deal " + R2S(udg_DamageEventAmount))
    endif
    set src = null
    set tgt = null
    return false
endfunction

//The traditional on-damage response, where armor reduction has already been factored in.
private function OnDamage takes nothing returns boolean
    local real r = GetEventDamage()
    local integer i
    if recursive then
        return false
    endif
    //call BJDebugMsg("Second event running")
    if preDamage then
        set preDamage = false   //This should be the case in almost all circumstances
    else
        set holdClear                   = false
        
        //Unfortunately, Spirit Link and Thorns Aura/Spiked Carapace fire the DAMAGED event out of sequence with the DAMAGING event,
        //so I have to re-generate a buncha stuff here.
        set udg_DamageEventAmount       = previousAmount
        set udg_DamageEventPrevAmt      = previousValue
        set udg_DamageEventType         = previousType
        set udg_IsDamageCode            = previousCode
        set udg_DamageEventSource       = GetEventDamageSource()
        set udg_DamageEventTarget       = BlzGetEventDamageTarget()
        set udg_DamageEventAttackT      = GetHandleId(BlzGetEventAttackType())
        set udg_DamageEventDamageT      = GetHandleId(BlzGetEventDamageType())
        set udg_DamageEventWeaponT      = GetHandleId(BlzGetEventWeaponType())
        
        call CalibrateMR() //Apply melee/ranged settings once again.
    endif
    
    set recursive = true
    if udg_DamageEventPrevAmt == 0.00 then
        set udg_DamageEvent = 0.00
        set udg_DamageEvent = 2.00
    else    
        if udg_DamageEventAmount != 0.00 then
            set udg_DamageScalingWC3 = r / udg_DamageEventAmount
        else
            set udg_DamageScalingWC3 = 0.00
        endif
        
        //DamageEventAmount remains unmodified by in-game damage processing for DamageTypePure.
        //Damage may have been further adjusted (ie. unit armor or armor type reduction)
        //Do not adjust in case damage was below zero because WC3 will have converted it to zero. 
        if udg_DamageScalingWC3 > 0.00 and not udg_DamageEventOverride then
            set udg_DamageEventAmount = r
        endif
        
        if udg_DamageEventAmount > 0.00 then
            //This event is used for custom shields which have a limited hit point value
            //The shield here kicks in after armor, so it acts like extra hit points.
            set udg_DamageModifierEvent = 0.00
            set udg_DamageModifierEvent = 4.00
            
            set udg_LethalDamageHP = GetWidgetLife(udg_DamageEventTarget) - udg_DamageEventAmount
            if udg_LethalDamageHP <= 0.405 then
                
                set udg_LethalDamageEvent = 0.00    //New - added 10 May 2019 to detect and potentially prevent lethal damage. Instead of
                set udg_LethalDamageEvent = 1.00    //modifying the damage, you need to modify LethalDamageHP instead (the final HP of the unit).
                
                set udg_DamageEventAmount = GetWidgetLife(udg_DamageEventTarget) - udg_LethalDamageHP
                if udg_DamageEventType < 0 and udg_LethalDamageHP <= 0.405 then
                    call SetUnitExploded(udg_DamageEventTarget, true)   //Explosive damage types should blow up the target.
                endif
            endif
        endif
        call BlzSetEventDamage(udg_DamageEventAmount)   //Apply the final damage amount.
        //if recursion > -1 then
            //call BJDebugMsg("Dealing " + R2S(udg_DamageEventAmount))
        //endif
        if udg_DamageEventDamageT != udg_DAMAGE_TYPE_UNKNOWN then
            set udg_DamageEvent = 0.00
            set udg_DamageEvent = 1.00
        endif
    endif
    set recursive = false
    if recursion > -1 then
        if not holdClear and not purge then
            set purge = true
            set i = -1
            //call BJDebugMsg("Clearing Recursion: " + I2S(recursion))
            loop
                exitwhen i >= recursion
                set i = i + 1 //Need to loop bottom to top to make sure damage order is preserved.
                
                set udg_NextDamageType = lastType[i]
                if lastTrig[i] != null then
                    call DisableTrigger(lastTrig[i])//Since the damage is run sequentially now, rather than recursively, the system needs to disable the user's trigger for them.
                endif
                //call BJDebugMsg("Stacking on " + R2S(lastAmount[i]))
                call UnitDamageTarget(lastSource[i], lastTarget[i], lastAmount[i], true, false, lastAttackT[i], lastDamageT[i], lastWeaponT[i])
            endloop
            loop
                exitwhen i <= -1
                if lastTrig[i] != null then
                    call EnableTrigger(lastTrig[i]) //Only re-enable recursive triggers AFTER all damage is dealt.
                endif
                set i = i - 1
            endloop
            //call BJDebugMsg("Cleared Recursion: " + I2S(recursion))
            set recursion = -1 //Can only be set after all the damage has successfully ended.
            set purge = false
        endif
    //else
        //call BJDebugMsg("Not Clearing Recursion: " + I2S(recursion) + ", HoldClear: " + I2S(IntegerTertiaryOp(holdClear, 1, 0)) + ", Purge: " + I2S(IntegerTertiaryOp(purge, 1, 0)))
    endif
    return false
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DAMAGING) //The new 1.31 event which fires before damage.
    call TriggerAddCondition(trig, Filter(function OnPreDamage))
    
    set trig = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DAMAGED) //Thanks to this I no longer have to have 1 event for all units in the map.
    call TriggerAddCondition(trig, Filter(function OnDamage))
endfunction

public function DebugStr takes nothing returns nothing
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
endfunction

//This function exists mainly to make it easier to switch from another DDS, like PDD.
function UnitDamageTargetEx takes unit src, unit tgt, real amt, boolean a, boolean r, attacktype at, damagetype dt, weapontype wt returns boolean
    if udg_DamageEventTrigger == null then
        set udg_DamageEventTrigger = GetTriggeringTrigger() //Directly access the user's calling trigger
    endif
    if udg_NextDamageType == 0 then
       set udg_NextDamageType = udg_DamageTypeCode 
    endif
    call UnitDamageTarget(src, tgt, amt, a, r, at, dt, wt)
    return recursive
endfunction

endlibrary 