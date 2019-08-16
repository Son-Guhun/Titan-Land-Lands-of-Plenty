//**************************************************************************************
//* Bonus Types Identifier:                                                            *
//*                                                                                    *
//* Armor Bonus:        0                                                              *
//* Attack Speed Bonus: 1                                                              *
//* Damage Bonus:       2                                                              *
//* Agility Bonus:      3                                                              *
//* Intelligence Bonus: 4                                                              *
//* Strength Bonus:     5                                                              *
//* Life Regen Bonus:   6                                                              *
//* Mana Regen Bonus:   7                                                              *
//* Life Bonus:         8                                                              *
//* Mana Bonus:         9                                                              *
//* Sight Range Bonus:  10                                                             *
//**************************************************************************************


//********************************************************************************
//* Generic Bonus APIs                                                           *
//*                                                                              *
//* CSS_GetBonus takes unit u, integer bonusType returns integer                 *
//* CSS_AddBonus takes unit u, integer amount, integer bonusType returns nothing *
//* CSS_ClearBonus takes unit u, integer bonusType                               *
//********************************************************************************


library CustomStatSystemConstants
    // Small addon by Guhun
    
private keyword InitModule

globals
    constant integer CSS_BONUS_ARMOR               = 0
    constant integer CSS_BONUS_ATTACK_SPEED       = 1
    constant integer CSS_BONUS_DAMAGE              = 2
    constant integer CSS_BONUS_AGILITY             = 3
    constant integer CSS_BONUS_INTELLIGENCE        = 4
    constant integer CSS_BONUS_STRENGTH            = 5
    constant integer CSS_BONUS_REGEN_LIFE          = 6
    constant integer CSS_BONUS_REGEN_MANA          = 7
    // constant integer CSS_BONUS_LIFE                = 8
    // constant integer CSS_BONUS_MANA                = 9
    constant integer CSS_BONUS_SIGHT_RANGE         = 10
endglobals

private struct Handlers extends array
    static method operator integer takes nothing returns integer
        return 1
    endmethod
    
    static method operator real takes nothing returns integer
        return 2
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

    call UnitAddAbility(u, abilCode)
    call UnitMakeAbilityPermanent(u, true, abilCode)
    set a = BlzGetUnitAbility(u, abilCode)
    
    if handler == Handlers.integer then
        set amount = amount + BlzGetAbilityIntegerLevelField(a, bonusType.integerField, 0)
        call BlzSetAbilityIntegerLevelField(a, bonusType.integerField, 0, amount)
        
        // Refresh ability (required in 1.31.1)
        call IncUnitAbilityLevel(u, abilCode)
        call SetUnitAbilityLevel(u, abilCode, 1)
        
        if bonusType == CSS_BONUS_REGEN_LIFE then  // Fix health and mana regen (in 1.31.1)
            set max = BlzGetUnitMaxHP(GetEnumUnit())
            call BlzSetUnitMaxHP(GetEnumUnit(), max + 1)
            call BlzSetUnitMaxHP(GetEnumUnit(), max)
        endif
    elseif handler == Handlers.real then
        set amount = amount + R2I((BlzGetAbilityRealLevelField(a, bonusType.realField, 0) * 100.) + 0.5)
        call BlzSetAbilityRealLevelField(a, bonusType.realField, 0, amount/100.)
        
        // Refresh ability (required in 1.31.1)
        call IncUnitAbilityLevel(u, abilCode)
        call SetUnitAbilityLevel(u, abilCode, 1)
        
        if bonusType == CSS_BONUS_REGEN_MANA then  // Fix health and mana regen (in 1.31.1)
            set max = BlzGetUnitMaxMana(GetEnumUnit())
            call BlzSetUnitMaxMana(GetEnumUnit(), max + 1)
            call BlzSetUnitMaxMana(GetEnumUnit(), max)
        endif
    endif
    
    set a = null
endfunction

function CSS_ClearBonus takes unit u, BonusType bonusType returns nothing
    call UnitRemoveAbility(u, bonusType.abilCode)
endfunction

function CSS_GetBonus takes unit u, BonusType bonusType returns integer
    local integer abilCode = bonusType.abilCode
    local integer handler = bonusType.handler
    local ability a
    
    if GetUnitAbilityLevel(u, abilCode) > 0 then
        set a = BlzGetUnitAbility(u, abilCode)
        
        if handler == Handlers.integer then
            return BlzGetAbilityIntegerLevelField(a, bonusType.integerField, 0)
        elseif handler == Handlers.real then
            return R2I((BlzGetAbilityRealLevelField(a, bonusType.realField, 0) * 100.) + 0.5)
        endif
    endif
    
    set a = null
    return 0
endfunction

module InitModule
    private static method onInit takes nothing returns nothing
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_ARMOR", "A00E", "integer", "ABILITY_ILF_DEFENSE_BONUS_IDEF")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_ATTACK_SPEED", "A01O", "real", "ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_DAMAGE", "A00P", "integer", "ABILITY_ILF_ATTACK_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_AGILITY", "A00Z", "integer", "ABILITY_ILF_AGILITY_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_INTELLIGENCE", "A00Z", "integer", "ABILITY_ILF_INTELLIGENCE_BONUS")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_STRENGTH", "A00Z", "integer", "ABILITY_ILF_STRENGTH_BONUS_ISTR")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_REGEN_LIFE", "A010", "integer", "ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND")
        //! runtextmacro GCSS_InitBonusType("CSS_BONUS_REGEN_MANA", "A021", "real", "ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL")
        // //! runtextmacro GCSS_InitBonusType("CSS_BONUS_LIFE", "A017", "integer", "ABILITY_ILF_MAX_LIFE_GAINED")
    endmethod
endmodule

//! textmacro GCSS_InitBonusType takes const, abilCode, type, field
    set BonusType($const$).abilCode = '$abilCode$'
    set BonusType($const$).$type$Field = $field$
    set BonusType($const$).handler = Handlers.$type$
//! endtextmacro
endlibrary