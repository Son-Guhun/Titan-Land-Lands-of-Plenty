library CustomStatSystem
//**************************************************************************************
//* Configuration:
private struct Abilities extends array
    static constant integer ARMOR        = 'A00E'
    static constant integer ATTACK_SPEED = 'A01O'
    static constant integer DAMAGE       = 'A00P'
    static constant integer AGILITY      = 'A00Z'
    static constant integer INTELLIGENCE = 'A00Z'
    static constant integer STRENGTH     = 'A00Z'
    static constant integer REGEN_LIFE   = 'A010'
    static constant integer REGEN_MANA   = 'A021'
    static constant integer LIFE         = 'A03D'
    static constant integer MANA         = 'A047'
endstruct
//**************************************************************************************


//********************************************************************************
//* Generic Bonus APIs                                                           *
//*                                                                              *
//* CSS_GetBonus takes unit u, integer bonusType returns integer                 *
//* CSS_AddBonus takes unit u, integer amount, integer bonusType returns nothing *
//* CSS_ClearBonus takes unit u, integer bonusType                               *
//*                                                                              *
//* Bonus Type constants:                                                        *
globals//                                                                        *
    constant integer CSS_BONUS_ARMOR               = 0  //                       *
    constant integer CSS_BONUS_ATTACK_SPEED        = 1  //                       * 
    constant integer CSS_BONUS_DAMAGE              = 2  //                       *
    constant integer CSS_BONUS_AGILITY             = 3  //                       *
    constant integer CSS_BONUS_INTELLIGENCE        = 4  //                       *
    constant integer CSS_BONUS_STRENGTH            = 5  //                       *
    constant integer CSS_BONUS_REGEN_LIFE          = 6  //                       *
    constant integer CSS_BONUS_REGEN_MANA          = 7  //                       *
    constant integer CSS_BONUS_LIFE                = 8  //                       *
    constant integer CSS_BONUS_MANA                = 9  //                       *
//  constant integer CSS_BONUS_SIGHT_RANGE         = 10 //                       *
endglobals//                                                                     *
//********************************************************************************

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

function CSS_AddBonus takes unit u, integer amount, BonusType bonusType returns nothing
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
        
        if bonusType == CSS_BONUS_REGEN_LIFE then  // Refresh health regen (required in 1.31.1)
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
        
        if bonusType == CSS_BONUS_REGEN_MANA then  // Refresh mana regen (required in 1.31.1)
            set max = BlzGetUnitMaxMana(GetEnumUnit())
            call BlzSetUnitMaxMana(GetEnumUnit(), max + 1)
            call BlzSetUnitMaxMana(GetEnumUnit(), max)
        endif
        
        
    elseif handler == Handlers.lifeMana then
        set max = amount + BlzGetAbilityIntegerLevelField(a, bonusType.integerField, 0)
        call BlzSetAbilityIntegerLevelField(a, bonusType.integerField, 0, -amount)
        call IncUnitAbilityLevel(u, abilCode)
        call SetUnitAbilityLevel(u, abilCode, 1)
        call UnitRemoveAbility(u, abilCode)
        
        call UnitAddAbility(u, abilCode)  // Add ability back (for getter function)
        call UnitMakeAbilityPermanent(u, true, abilCode)
        call BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, abilCode), bonusType.integerField, 0, max)
    endif
    
    set a = null
endfunction

function CSS_GetBonus takes unit u, BonusType bonusType returns integer
    local integer abilCode = bonusType.abilCode
    local integer handler = bonusType.handler
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
    endif
    
    set a = null
    return handler
endfunction

function CSS_ClearBonus takes unit u, BonusType bonusType returns nothing
    if bonusType.handler == Handlers.lifeMana then
        call CSS_AddBonus(u, -CSS_GetBonus(u, bonusType), bonusType)
    endif
    
    call UnitRemoveAbility(u, bonusType.abilCode)
endfunction

module InitModule
    private static method onInit takes nothing returns nothing
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_ARMOR",        "Abilities.ARMOR",        "integer", "ABILITY_ILF_DEFENSE_BONUS_IDEF")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_ATTACK_SPEED", "Abilities.ATTACK_SPEED", "real",    "ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_DAMAGE",       "Abilities.DAMAGE",       "integer", "ABILITY_ILF_ATTACK_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_AGILITY",      "Abilities.AGILITY",      "integer", "ABILITY_ILF_AGILITY_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_INTELLIGENCE", "Abilities.INTELLIGENCE", "integer", "ABILITY_ILF_INTELLIGENCE_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_STRENGTH",     "Abilities.STRENGTH",     "integer", "ABILITY_ILF_STRENGTH_BONUS_ISTR")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_REGEN_LIFE",   "Abilities.REGEN_LIFE",   "integer", "ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_REGEN_MANA",   "Abilities.REGEN_MANA",   "real",    "ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_LIFE",         "Abilities.LIFE",         "integer", "ABILITY_ILF_MAX_LIFE_GAINED")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_MANA",         "Abilities.MANA",         "integer", "ABILITY_ILF_MAX_MANA_GAINED")
        
        set BonusType(CSS_BONUS_LIFE).handler = Handlers.lifeMana
        set BonusType(CSS_BONUS_MANA).handler = Handlers.lifeMana
    endmethod
endmodule

//! textmacro GCSS_InitBonusType takes const, abilCode, type, field
    set BonusType($const$).abilCode = $abilCode$
    set BonusType($const$).$type$Field = $field$
    set BonusType($const$).handler = Handlers.$type$
//! endtextmacro
endlibrary