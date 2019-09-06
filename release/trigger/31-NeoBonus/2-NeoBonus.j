library NeoBonus
//*****************************************************************************************************
/* How to import:                                                                                     *
                                                                                                      *
1- Copy this trigger into your map.                                                                   *
1- For each bonus that you are going to use, copy the correspoding ability into your map.             *            
2- In your map, press Ctrl+D while in the Object Editor to see raw data.                              *
3- Type the rawcode (4 letter code) of each ability into its respective variable in the config below. *
                                                                                                      * 
*///* Configuration:                                                                                  *
private struct Abilities extends array//                                                              *
    static constant integer ARMOR        = 'A00E'  // NeoBonus_Armor                                  *
    static constant integer ATTACK_SPEED = 'A01O'  // NeoBonus_Attack Speed                           *
    static constant integer DAMAGE       = 'A00P'  // NeoBonus_Damage                                 *
    static constant integer AGILITY      = 'A00Z'  // NeoBonus_Attributes                             *
    static constant integer INTELLIGENCE = 'A00Z'  // NeoBonus_Attributes                             *
    static constant integer STRENGTH     = 'A00Z'  // NeoBonus_Attributes                             *
    static constant integer REGEN_LIFE   = 'A010'  // NeoBonus_Regen Life                             *
    static constant integer REGEN_MANA   = 'A021'  // NeoBonus_Regen Mana                             *
    static constant integer LIFE         = 'A03D'  // NeoBonus_Max Life                               *
    static constant integer MANA         = 'A047'  // NeoBonus_Max Mana                               *
    static constant integer SIGHT_RANGE  = 0       // NeoBonus_Max Mana                               *
endstruct//                                                                                           *
//*****************************************************************************************************


//***************************************************************************************
//* API                                                                                 *
//*                                                                                     *
//* Functions:                                                                          *
//! novjass                                                                             *
//                                                                                      *
function UnitAddBonus takes unit u, integer bonusType, integer amount returns boolean   *
//! Returns false if bonusType is an invalid value (see constants below).               *
//                                                                                      *
function UnitGetBonus takes unit u, integer bonusType returns integer                   *
//                                                                                      *
//                                                                                      *
// Advanced functions                                                                   *
// It is advised to only use the Adder and Getter functions.                            *
function UnitClearBonus takes unit u, integer bonusType returns nothing                 *
//! Removes the bonus ability from the specified unit, effectively setting bonus to 0.  *
//                                                                                      *
function UnitSetBonus takes unit u, integer bonusType, integer amount returns boolean   *
//! Calls UnitClearBonus and then returns UnitAddBonus with the specified parameters.   *
//                                                                                      *
//! endnovjass                                                                          *
//*                                                                                     *
//* Bonus Type constants:                                                               *
globals//                                                                               *
    constant integer BONUS_ARMOR        = 0  //                                         *
    constant integer BONUS_DAMAGE       = 1  //                                         * 
    constant integer BONUS_SIGHT_RANGE  = 2  //                                         *
    constant integer BONUS_MANA_REGEN   = 3  // %                                       *
    constant integer BONUS_LIFE_REGEN   = 4  //                                         *
    constant integer BONUS_HERO_STR     = 5  //                                         *
    constant integer BONUS_HERO_AGI     = 6  //                                         *
    constant integer BONUS_HERO_INT     = 7  //                                         *
    constant integer BONUS_MANA         = 8  //                                         *
    constant integer BONUS_LIFE         = 9  //                                         *
    constant integer BONUS_ATTACK_SPEED = 10 // %                                       *
endglobals//                                                                            *
//***************************************************************************************

// ****************
// Source Code
// ****************

private keyword InitModule

private struct Handlers extends array
    static constant method operator integer takes nothing returns integer
        return 1
    endmethod
    
    static constant method operator real takes nothing returns integer
        return 2
    endmethod
    
    static constant method operator lifeMana takes nothing returns integer
        return 3
    endmethod
endstruct

private struct BonusType extends array
    public integer abilCode
    public abilityintegerlevelfield integerField
    public abilityreallevelfield realField
    public integer handler
    
    implement InitModule
endstruct

private struct HandlerFuncs extends array
    private static method GetAbilityOverload takes ability a returns integer
        return BlzGetAbilityIntegerField(a, ABILITY_IF_MISSILE_SPEED)
    endmethod
    
    private static method SetAbilityOverload takes ability a, integer amount returns nothing
        call BlzSetAbilityIntegerField(a, ABILITY_IF_MISSILE_SPEED, amount)
    endmethod

    static method lifeMana takes unit u, BonusType bonusType, integer amount, integer abilCode, ability a returns nothing
        local abilityintegerlevelfield field = bonusType.integerField
        local integer total = amount + BlzGetAbilityIntegerLevelField(a, field, 0)
        local integer minValue
        local integer overload = GetAbilityOverload(a)
        
        if overload > 0 then
            if amount > overload then
                set amount = amount - overload
                set overload = 0
            else
                set overload = GetAbilityOverload(a) - amount
                set amount = 0
            endif
        elseif amount < 0 then // Check for new overload
            if bonusType == BONUS_MANA then
                set minValue = -BlzGetUnitMaxMana(u)
            else
                set minValue = -BlzGetUnitMaxHP(u) + 1
            endif
            
            if amount < minValue then
                set overload = minValue - amount
                set amount = minValue
            endif           
        endif
        
        if amount != 0 then
            call BlzSetAbilityIntegerLevelField(a, field, 0, -amount)
            call IncUnitAbilityLevel(u, abilCode)
            call SetUnitAbilityLevel(u, abilCode, 1)
            call UnitRemoveAbility(u, abilCode)
            
            call UnitAddAbility(u, abilCode)  // Add ability back (to store total and overload)
            call UnitMakeAbilityPermanent(u, true, abilCode)
            set a = BlzGetUnitAbility(u, abilCode)
        endif
    
        call BlzSetAbilityIntegerLevelField(a, field, 0, total)
        call SetAbilityOverload(a, overload)
    endmethod
endstruct

function UnitAddBonus takes unit u, BonusType bonusType, integer amount returns boolean
    local integer abilCode = bonusType.abilCode
    local integer handler = bonusType.handler
    local ability a
    local integer max

    if UnitAddAbility(u, abilCode) then
        call UnitMakeAbilityPermanent(u, true, abilCode)
    endif
    set a = BlzGetUnitAbility(u, abilCode)
    
    if handler == Handlers.integer then
        set amount = amount + BlzGetAbilityIntegerLevelField(a, bonusType.integerField, 0)
        call BlzSetAbilityIntegerLevelField(a, bonusType.integerField, 0, amount)
        
        // Refresh ability (required in 1.31.1)
        call IncUnitAbilityLevel(u, abilCode)
        call SetUnitAbilityLevel(u, abilCode, 1)
        
        if bonusType == BONUS_LIFE_REGEN then  // Refresh health regen (required in 1.31.1)
            //set max = BlzGetUnitMaxHP(GetEnumUnit())
            call UnitAddAbility(u, 'AIl2')
            call UnitRemoveAbility(u, 'AIl2')
            //call BlzSetUnitMaxHP(GetEnumUnit(), max + 1)
            //call BlzSetUnitMaxHP(GetEnumUnit(), max)
        endif
        
        
    elseif handler == Handlers.real then
        set amount = amount + R2I((BlzGetAbilityRealLevelField(a, bonusType.realField, 0) * 100.) + 0.5)
        call BlzSetAbilityRealLevelField(a, bonusType.realField, 0, amount/100.)
        
        // Refresh ability (required in 1.31.1)
        call IncUnitAbilityLevel(u, abilCode)
        call SetUnitAbilityLevel(u, abilCode, 1)
        
        if bonusType == BONUS_MANA_REGEN then  // Refresh mana regen (required in 1.31.1)
            set max = BlzGetUnitMaxMana(GetEnumUnit())
            call BlzSetUnitMaxMana(GetEnumUnit(), max + 1)
            call BlzSetUnitMaxMana(GetEnumUnit(), max)
        endif
        
        
    elseif handler == Handlers.lifeMana then
        call HandlerFuncs.lifeMana(u, bonusType, amount, abilCode, a)
    
    else
        return false
    endif
    
    set a = null
    return true
endfunction

function UnitGetBonus takes unit u, BonusType bonusType returns integer
    local integer abilCode = bonusType.abilCode
    local integer handler = bonusType.handler  // after check, this will hold return value
    local ability a
    
    if GetUnitAbilityLevel(u, abilCode) > 0 then
        set a = BlzGetUnitAbility(u, abilCode)
        
        if handler == Handlers.integer or handler == Handlers.lifeMana then
            set handler = BlzGetAbilityIntegerLevelField(a, bonusType.integerField, 0)
        elseif handler == Handlers.real then
            set handler = R2I((BlzGetAbilityRealLevelField(a, bonusType.realField, 0) * 100.) + 0.5)
        else
            set handler = 0
        endif
    else
        return 0
    endif
    
    set a = null
    return handler
endfunction

function UnitClearBonus takes unit u, BonusType bonusType returns nothing
    if bonusType.handler == Handlers.lifeMana then
        call UnitAddBonus(u, -UnitGetBonus(u, bonusType), bonusType)
    endif
    
    call UnitRemoveAbility(u, bonusType.abilCode)
endfunction

function UnitSetBonus takes unit u, BonusType bonusType, integer amount returns boolean
    call UnitClearBonus(u, bonusType)
    return UnitAddBonus(u, bonusType, amount)
endfunction

module InitModule
    private static method onInit takes nothing returns nothing
        //! runtextmacro NeoBonus_InitBonusType("BONUS_ARMOR",        "Abilities.ARMOR",        "integer", "ABILITY_ILF_DEFENSE_BONUS_IDEF")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_DAMAGE",       "Abilities.DAMAGE",       "integer", "ABILITY_ILF_ATTACK_BONUS")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_LIFE_REGEN",   "Abilities.REGEN_LIFE",   "integer", "ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_MANA_REGEN",   "Abilities.REGEN_MANA",   "real",    "ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_HERO_AGI",     "Abilities.AGILITY",      "integer", "ABILITY_ILF_AGILITY_BONUS")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_HERO_INT",     "Abilities.INTELLIGENCE", "integer", "ABILITY_ILF_INTELLIGENCE_BONUS")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_HERO_STR",     "Abilities.STRENGTH",     "integer", "ABILITY_ILF_STRENGTH_BONUS_ISTR")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_LIFE",         "Abilities.LIFE",         "integer", "ABILITY_ILF_MAX_LIFE_GAINED")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_MANA",         "Abilities.MANA",         "integer", "ABILITY_ILF_MAX_MANA_GAINED")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_ATTACK_SPEED", "Abilities.ATTACK_SPEED", "real",    "ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1")
        //! runtextmacro NeoBonus_InitBonusType("BONUS_SIGHT_RANGE",  "Abilities.SIGHT_RANGE",  "integer", "ABILITY_ILF_SIGHT_RANGE_BONUS")
                
        set BonusType(BONUS_LIFE).handler = Handlers.lifeMana
        set BonusType(BONUS_MANA).handler = Handlers.lifeMana
    endmethod
endmodule

//! textmacro NeoBonus_InitBonusType takes const, abilCode, type, field
    set BonusType($const$).abilCode = $abilCode$
    set BonusType($const$).$type$Field = $field$
    set BonusType($const$).handler = Handlers.$type$
//! endtextmacro
endlibrary