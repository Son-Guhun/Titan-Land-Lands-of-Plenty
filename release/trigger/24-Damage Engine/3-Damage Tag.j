globals

    boolean ENABLE_TAGS = false

endglobals

function DamageDetectionFunctions_Both takes nothing returns nothing
    if LoP_IsUnitHero(udg_DamageEventTarget) then
        // Blessed Bulwark
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A04J') > 0 then
            set udg_Damage_Mod_Multiplier = ( udg_Damage_Mod_Multiplier * 0.90)
        endif
        
        // Profaned Aegis
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A04K') > 0 then
            set udg_Damage_Mod_Multiplier = ( udg_Damage_Mod_Multiplier * 0.85)
        endif
    endif

    //Divine Shell
    if ( GetUnitAbilityLevel(udg_DamageEventTarget, 'B02C') > 0) then
        set udg_Damage_Mod_Multiplier = ( udg_Damage_Mod_Multiplier / 2.00 )
    endif

    if GetUnitAbilityLevel(udg_DamageEventTarget, 'A030') > 0 then
        if udg_DamageEventAmount > 100 then
            set udg_Damage_Mod_Maximum = 100
        endif
    endif
    //--------------

    //Aura of Retribution (Tyrael)
    if GetUnitAbilityLevel(udg_DamageEventTarget, 'B000') > 0 then
        set udg_Damage_Mod_Multiplier = udg_Damage_Mod_Multiplier * 0.90
    endif

    //Heaven's Reckoning (Tyrael)
    if ( GetUnitAbilityLevel(udg_DamageEventSource, 'B02X') > 0 ) then
        set udg_GDS_Type = udg_GDS_cSTUN
        set udg_GDS_Target = udg_DamageEventSource
        if IsUnitType(udg_DamageEventSource, UNIT_TYPE_HERO) then
            set udg_GDS_Duration = 0.66
        else
            set udg_GDS_Duration = 1.01
        endif
        call TriggerExecute( gg_trg_GDS_Main_Modifier )
    endif
endfunction

function DamageDetectionFunctions_Spell takes nothing returns nothing
    //Storm Bolt Stun (AoE & non-AoE)
    if ( GetUnitAbilityLevel(udg_DamageEventTarget, 'B01W') > 0 ) then
        call UnitRemoveAbility( udg_DamageEventTarget, 'B01W' )
        set udg_GDS_Type = udg_GDS_cSTUN
        if IsUnitType(udg_DamageEventTarget, UNIT_TYPE_HERO) then
            set udg_GDS_Duration = 3.00
        else
            set udg_GDS_Duration = 5.00
        endif
        set udg_GDS_Target = udg_DamageEventTarget
        call TriggerExecute( gg_trg_GDS_Main_Modifier )
    endif


    //Greater Frost Armor (Spell Damage Reduction)
    if GetUnitAbilityLevel(udg_DamageEventTarget, 'B02R') > 0 then
        set udg_Damage_Mod_Multiplier = udg_Damage_Mod_Multiplier * 0.75
    endif
    
    // ======
    // Hero-only abilities
    // ======
    if GetUnitAbilityLevel(udg_DamageEventTarget, 'AHer') > 0 then
        
        // Arcane Warding
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A018') >0 then
            set udg_Damage_Mod_Multiplier = udg_Damage_Mod_Multiplier * 0.67
        endif
        
        // Nature's Wrath
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A01C') >0 then
            set udg_Damage_Mod_Multiplier = udg_Damage_Mod_Multiplier * 0.80
        endif
        
        //  Lion's Strike passive (Anduin Lothar)
        if ( GetUnitAbilityLevel(udg_DamageEventSource,'A023') != 0 and  GetRandomInt(1, 10) <= 5) then
            set udg_Damage_Mod_Multiplier = ( udg_Damage_Mod_Multiplier * 1.50 )
            set udg_GDS_Type = udg_GDS_cSTUN
            set udg_GDS_Duration = 1.50
            set udg_GDS_Target = udg_DamageEventTarget
            call TriggerExecute( gg_trg_GDS_Main_Modifier )
        endif
        
    endif
endfunction

function DamageDetectionFunctions_Last takes nothing returns nothing
    local real storeDamage = udg_DamageEventAmount
    local integer sourceUserData
    
    // Aura of Resitution
    if GetUnitAbilityLevel(udg_DamageEventSource, 'A05Q') > 0 then
        set sourceUserData = GetUnitUserData(udg_DamageEventSource)
        if udg_Abilities_AoRest_DmgDone[sourceUserData] == 0 then
            call GroupAddUnit(udg_Abilities_AoRest_UnitGroup, udg_DamageEventSource)
            set udg_Abilities_AoRest_DmgDone[sourceUserData] = udg_DamageEventAmount
        else
            set udg_Abilities_AoRest_DmgDone[sourceUserData] = udg_DamageEventAmount + udg_Abilities_AoRest_DmgDone[sourceUserData]
        endif
    endif
    
    //Aura of Retribution
    if GetUnitAbilityLevel(udg_DamageEventTarget, 'B000') > 0 then
        set udg_Damage_Mod_Reset = false
        set udg_Damage_Mod_Multiplier = 1.
        set udg_Damage_Mod_Add = 0.
        set udg_Damage_Mod_Minimum = 10.
        set udg_Damage_Mod_Maximum = -1.
        set udg_Damage_Mod_AllowReflect = false
        call UnitDamageTarget(udg_DamageEventTarget, udg_DamageEventSource, udg_DamageEventAmount * 10/90, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_DEFENSIVE, WEAPON_TYPE_WHOKNOWS)
        set udg_DamageEventAmount = storeDamage
    endif
    
    //Lich King (The Immortal King passive)
    if GetUnitAbilityLevel(udg_DamageEventSource, 'A030') > 0 then
        call SetUnitState(udg_DamageEventSource, UNIT_STATE_LIFE, RMaxBJ(0,GetUnitState(udg_DamageEventSource, UNIT_STATE_LIFE) + udg_DamageEventAmount/5))
        call SetUnitState(udg_DamageEventSource, UNIT_STATE_MANA, RMaxBJ(0,GetUnitState(udg_DamageEventSource, UNIT_STATE_MANA) + udg_DamageEventAmount/10))
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl", udg_DamageEventSource, "origin"))
        call CreateTextTagUnitBJ( ( "+" + I2S(R2I(RAbsBJ(udg_DamageEventAmount/5))) ), udg_DamageEventSource, 50.00, 13.00, 5.00, 100.00, 10.00, 0 )
        call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 75.00, 90.00 )
        call SetTextTagPermanent( bj_lastCreatedTextTag, false )
        call SetTextTagLifespan( bj_lastCreatedTextTag, 3.50 )
        call SetTextTagFadepoint( bj_lastCreatedTextTag, 1.40 )
    endif
    
    if LoP_IsUnitHero(udg_DamageEventTarget) then
        // Blessed Bulwark
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A04J') > 0 then
            set udg_TimerBonuses[CSS_BONUS_REGEN_LIFE] = R2I(udg_DamageEventAmount/30 + 0.5)
            call AddTimedBonus(udg_DamageEventTarget, 0, 1, 10.)
        endif
        
        // Profaned Aegis
        if GetUnitAbilityLevel(udg_DamageEventTarget, 'A04K') > 0 then
            set udg_TimerBonuses[CSS_BONUS_REGEN_LIFE] = -R2I(udg_DamageEventAmount/20 + 0.5)
            call AddTimedBonus(udg_DamageEventSource, 0, 1, 5.)
        endif
    endif
endfunction

globals
    key MSGKEY_DAMAGE
    key MSGKEY_DAMAGED
endglobals

// When a unit is removed from the game, DamageEventSource is null
function Trig_Damage_Tag_Actions takes nothing returns nothing
    local integer damageType
    local player targetOwner = LoP_GetOwningPlayer(udg_DamageEventTarget)
    local player sourceOwner = GetOwningPlayer(udg_DamageEventSource)
    
    if udg_DamageEventSource == null or sourceOwner == null then
        return
    endif
    
    // Getting the alliance state with a null player will crash the game
    if GetPlayerId(targetOwner) < bj_MAX_PLAYERS and GetPlayerSlotState(targetOwner) == PLAYER_SLOT_STATE_PLAYING then
        if not LoP_PlayerData.get(targetOwner).isAtWar(sourceOwner) and GetPlayerAlliance(targetOwner, sourceOwner, ALLIANCE_PASSIVE) then
            if targetOwner != sourceOwner then
            
                call LoP_WarnPlayerTimeout(targetOwner, LoPChannels.WARNING, MSGKEY_DAMAGED, 7.5, "Use the -war command to allow others to damage your units.")
                call LoP_WarnPlayerTimeout(sourceOwner, LoPChannels.WARNING, MSGKEY_DAMAGE, 10., "You cannot damage units of players that are allied to you!")
                set udg_DamageEventAmount = 0
                return
            endif
        endif
    endif

    if udg_Damage_Mod_Reset then
        set udg_Damage_Mod_Multiplier = 1.
        set udg_Damage_Mod_Add = 0.
        set udg_Damage_Mod_Minimum = 0.
        set udg_Damage_Mod_Maximum = -1.
    else
        set udg_Damage_Mod_Reset = true
    endif
    if udg_DamageTypeSpell then
        set udg_IsDamageSpell = true
        set udg_DamageTypeSpell = false
    endif
    
    //Check if damaging unit is a dummy
    if DummyDmg_IsDummy(DummyDmg_GetKey(udg_DamageEventSource)) then
        debug call BJDebugMsg("Debug message: Dummy damage detected!")
        if DummyDmg_HasTrigger(DummyDmg_GetKey(udg_DamageEventSource)) then
            call TriggerEvaluate(LoadTriggerHandle(udg_Hashtable_2, DummyDmg_GetAbility(DummyDmg_GetKey(udg_DamageEventSource)) , 0))
        endif
        //if IsUnitType(udg_DamageEventTarget, UNIT_TYPE_ETHEREAL) then
            //Unit is ETHEREAL, thus can't deal universal physical damage
            //No way to fix the damage source, change Source variable to Spellcaster
            set udg_DamageEventSource = DummyDmg_GetCaster(DummyDmg_GetKey(udg_DamageEventSource))
        /*else
            //Make damage dealt 0 and make Spellcaster deal damage equal to damage dealt
            //Deal Chaos damage (no reduction or increase by armor) of type Universal
            set udg_DamageTypeSpell = true
            call UnitDamageTarget(DummyDmg_GetCaster(DummyDmg_GetKey(udg_DamageEventSource)), udg_DamageEventTarget, udg_DamageEventAmount, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS)
            set udg_DamageEventAmount = 0
            return
        endif
        */
    endif
    
    if udg_DamageEventDamageT != GetHandleId(DAMAGE_TYPE_SPIRIT_LINK) then

        call DamageDetectionFunctions_Both()
        
        if ( udg_IsDamageSpell == true ) then
            call DamageDetectionFunctions_Spell()
            set damageType = CombatTag_SPELL_DAMAGE
        else
            // call DamageDetectionFunctions_Physical()
            set damageType = CombatTag_PHYS_DAMAGE
        endif
        
        set udg_DamageEventAmount = (udg_DamageEventAmount + udg_Damage_Mod_Add)*udg_Damage_Mod_Multiplier
        if udg_Damage_Mod_Minimum > udg_DamageEventAmount then
            set udg_DamageEventAmount = udg_Damage_Mod_Minimum
        elseif udg_Damage_Mod_Maximum >= 0. and udg_Damage_Mod_Maximum < udg_DamageEventAmount then
            set udg_DamageEventAmount = udg_Damage_Mod_Maximum
        endif
            
        if udg_Damage_Mod_AllowReflect then
            call DamageDetectionFunctions_Last()
        else
            set udg_Damage_Mod_AllowReflect = true
        endif
        
    endif
    
    if ENABLE_TAGS then
        call CombatTag_Register(udg_DamageEventTarget, udg_DamageEventAmount, damageType)
    endif
endfunction

//===========================================================================
function InitTrig_Damage_Tag takes nothing returns nothing
    set gg_trg_Damage_Tag = CreateTrigger(  )
    call DamageEngine_SetupEvent( gg_trg_Damage_Tag, "udg_DamageModifierEvent", 4 )
    call TriggerAddAction( gg_trg_Damage_Tag, function Trig_Damage_Tag_Actions )
endfunction

