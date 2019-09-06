library CustomStatSystem requires NeoBonus
//**************************************************************************************
/* How to import:

1- You must follow the instructions in the NeoBonus library in order to import it.
2- You must follow the instructions in the CustomStatSystem triggers to import it. You do not need to
use the Lua script or copy over any abilities, just the actual JASS code.
3- In the code you imported to the Map Header for CSS, deleate everything below the line "// Bonus Handling Code".
4- Delete the CSS Standalone Bonus trigger from the CSS System category.
5- Import this trigger into your map.

*///************************************************************************************

//******************************************************************************
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
    constant integer CSS_BONUS_SIGHT_RANGE         = 10 //                       *
endglobals//                                                                     *
//********************************************************************************

private keyword InitModule

private struct BonusType extends array
    public integer asNeoBonus
    
    implement InitModule
endstruct

function CSS_AddBonus takes unit u, integer amount, BonusType bonusType returns nothing
    call UnitAddBonus(u, bonusType.asNeoBonus, amount)
endfunction

function CSS_GetBonus takes unit u, BonusType bonusType returns integer
    return UnitGetBonus(u, bonusType.asNeoBonus)
endfunction

function CSS_ClearBonus takes unit u, BonusType bonusType returns nothing
    call UnitClearBonus(u, bonusType.asNeoBonus)
endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        set BonusType(CSS_BONUS_ARMOR).asNeoBonus        = BONUS_ARMOR
        set BonusType(CSS_BONUS_ATTACK_SPEED).asNeoBonus = BONUS_ATTACK_SPEED
        set BonusType(CSS_BONUS_DAMAGE).asNeoBonus       = BONUS_DAMAGE
        set BonusType(CSS_BONUS_AGILITY).asNeoBonus      = BONUS_HERO_AGI
        set BonusType(CSS_BONUS_INTELLIGENCE).asNeoBonus = BONUS_HERO_INT
        set BonusType(CSS_BONUS_STRENGTH).asNeoBonus     = BONUS_HERO_STR
        set BonusType(CSS_BONUS_REGEN_LIFE).asNeoBonus   = BONUS_LIFE_REGEN
        set BonusType(CSS_BONUS_REGEN_MANA).asNeoBonus   = BONUS_MANA_REGEN
        set BonusType(CSS_BONUS_LIFE).asNeoBonus         = BONUS_LIFE
        set BonusType(CSS_BONUS_MANA).asNeoBonus         = BONUS_MANA
        set BonusType(CSS_BONUS_SIGHT_RANGE).asNeoBonus  = BONUS_SIGHT_RANGE
    endmethod
endmodule
endlibrary