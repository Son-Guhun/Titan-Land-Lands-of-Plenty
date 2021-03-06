library LoPDecoBuilders requires LoPHeader, TableStruct
/*
    This library defines functions to initialize the values of the rawcodes[] array, which
should contain the rawcodes of all existing Deco Builders, in alphabetical order. Special builders 
are listed first, though.


struct LoP_DecoBuilders:

    Static Fields:
        integer[] rawcodes  -> an array containing rawcodes in [SpecialDecoFirstIndex, DecoLastIndex].
        integer[] reforgedRawcodes  -> an array containing rawcodes in [SpecialDecoFirstIndex, ReforgedDecoLastIndex].
        
        integer SpecialDecoFirstIndex
        integer SpecialDecoLastIndex
        integer BasicDecoFirstIndex
        integer BasicDecoLastIndex
        integer AdvDecoFirstIndex
        integer AdvDecoLastIndex
        integer DecoLastIndex
        integer ReforgedDecoLastIndex
        
Constants:
    integer DECO_BUILDER_SPECIAL  -> rawcode for Deco Builder special.
    
    . Constants to be used as last parameter given to LoPDecoBuilders_CreateMissing:
    .   boolean DECO_BUILDERS_CLASSIC
    .   boolean DECO_BUILDERS_REFORGED

Functions:
    nothing LoPDecoBuilders_AdjustSpecialAbilities(unit deco)

*/

globals
    constant integer DECO_BUILDER_SPECIAL = 'u015'
    
    constant boolean DECO_BUILDERS_CLASSIC = false
    constant boolean DECO_BUILDERS_REFORGED = true
endglobals

public function AdjustSpecialAbilities takes unit deco returns nothing
    local integer playerNumber = GetPlayerId(GetOwningPlayer(deco)) + 1
    call BlzSetAbilityRealLevelField(BlzGetUnitAbility(deco, 'A01S'), ABILITY_RLF_AREA_OF_EFFECT, 0, 100.*udg_DecoSystem_Value[playerNumber])
    call UnitRemoveAbility(deco, 'A03N')
    call UnitAddAbility(deco, 'A03N')
    call BlzSetAbilityRealLevelField(BlzGetUnitAbility(deco, 'A03N'), ABILITY_RLF_AREA_OF_EFFECT, 0, 100.*udg_DecoSystem_Value[playerNumber])
endfunction

private module InitModule    
    private static method onInit takes nothing returns nothing
        local integer i = 0
        // ---------
        // Special Decos
        // ---------
        // Units and Trees
        set rawcodes[i] = 'u015'
        // Terrain
        set i = ( i + 1 )
        set rawcodes[i] = 'u02E'
        // Docks
        set i = ( i + 1 )
        set rawcodes[i] = 'u003'
        // Misc
        set i = ( i + 1 )
        set rawcodes[i] = 'u00W'
        
        set LoP_DecoBuilders.SpecialDecoLastIndex = i
        // ---------
        // Basic Decos
        // ---------
        // Archways
        set i = ( i + 1 )
        set rawcodes[i] = 'u014'
        // Blacksmith
        set i = ( i + 1 )
        set rawcodes[i] = 'u01E'
        // Bushes
        set i = ( i + 1 )
        set rawcodes[i] = 'u00A'
        // Camp
        set i = ( i + 1 )
        set rawcodes[i] = 'u035'
        // City 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u016'
        // City 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u017'
        // City 3
        set i = ( i + 1 )
        set rawcodes[i] = 'u01T'
        // Columns
        set i = ( i + 1 )
        set rawcodes[i] = 'u06P'        
        // Corpses
        set i = ( i + 1 )
        set rawcodes[i] = 'u00N'
        // Crops
        set i = ( i + 1 )
        set rawcodes[i] = 'u00B'
        // Dungeon
        set i = ( i + 1 )
        set rawcodes[i] = 'u01P'
        // Effects
        set i = ( i + 1 )
        set rawcodes[i] = 'u036'
        // Fence
        set i = ( i + 1 )
        set rawcodes[i] = 'u03I'
        // Fire
        set i = ( i + 1 )
        set rawcodes[i] = 'u01C'
        // Flags
        set i = ( i + 1 )
        set rawcodes[i] = 'u005'
        // Flowers 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u004'
        // Furniture Deco
        set i = ( i + 1 )
        set rawcodes[i] = 'u03Q'
        // Gates
        set i = ( i + 1 )
        set rawcodes[i] = 'u00V'
        // Gravestones
        set i = ( i + 1 )
        set rawcodes[i] = 'u02S'
        // Ice
        set i = ( i + 1 )
        set rawcodes[i] = 'u03P'
        // Market
        set i = ( i + 1 )
        set rawcodes[i] = 'u01D'
        // NPC
        set i = ( i + 1 )
        set rawcodes[i] = 'u048'
        // Obelisks
        set i = ( i + 1 )
        set rawcodes[i] = 'u00Y'
        // Rocks
        set i = ( i + 1 )
        set rawcodes[i] = 'u013'
        // Ruined 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u02T'
        // Seats
        set i = ( i + 1 )
        set rawcodes[i] = 'u01R'
        // Statue 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u01N'
        // Trees
        set i = ( i + 1 )
        set rawcodes[i] = 'u01B'
        // Walls (Original)
        set i = ( i + 1 )
        set rawcodes[i] = 'u000'
        // Water
        set i = ( i + 1 )
        set rawcodes[i] = 'u00Z'
        // Webs
        set i = ( i + 1 )
        set rawcodes[i] = 'u02P'
        
        set LoP_DecoBuilders.BasicDecoLastIndex = i
        // ---------
        // Advanced Decos
        // ---------
        // Arabian 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u02G'
        // Arabian 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u02H'
        // Black Empire
        set i = ( i + 1 )
        set rawcodes[i] = 'u00T'
        // Blocks
        set i = ( i + 1 )
        set rawcodes[i] = 'u03A'
        // Castle
        set i = ( i + 1 )
        set rawcodes[i] = 'u00M'
        // Celtic
        set i = ( i + 1 )
        set rawcodes[i] = 'u029'
        // Chaos
        set i = ( i + 1 )
        set rawcodes[i] = 'u039'
        // Creeps
        set i = ( i + 1 )
        set rawcodes[i] = 'u06M'
        // Dalaran
        set i = ( i + 1 )
        set rawcodes[i] = 'u02D'
        // Dalaran Modular 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u012'
        // Dalaran Modular 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u010'
        // Draenei
        set i = ( i + 1 )
        set rawcodes[i] = 'u02O'
        // Drow
        set i = ( i + 1 )
        set rawcodes[i] = 'u03Z'
        // Elves Blood
        set i = ( i + 1 )
        set rawcodes[i] = 'u02A'
        // Elves High
        set i = ( i + 1 )
        set rawcodes[i] = 'u045'
        // Elves Forest
        set i = ( i + 1 )
        set rawcodes[i] = 'u040'
        // Elves Night
        set i = ( i + 1 )
        set rawcodes[i] = 'u06N'
        // Feudal
        set i = ( i + 1 )
        set rawcodes[i] = 'u01S'
        // Floors
        set i = ( i + 1 )
        set rawcodes[i] = 'u02C'
        // Flowers 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u006'
        // Forsaken
        set i = ( i + 1 )
        set rawcodes[i] = 'u025'
        // Games
        set i = ( i + 1 )
        set rawcodes[i] = 'u027'
        // Goblin
        set i = ( i + 1 )
        set rawcodes[i] = 'u02R'
        // Gurubashi
        set i = ( i + 1 )
        set rawcodes[i] = 'u00O'
        // Hellfire Citadel
        set i = ( i + 1 )
        set rawcodes[i] = 'u04W'
        // Human
        set i = ( i + 1 )
        set rawcodes[i] = 'u06I'
        // Huts
        set i = ( i + 1 )
        set rawcodes[i] = 'u002'
        // Icecrown
        set i = ( i + 1 )
        set rawcodes[i] = 'u061'
        // Mansion
        set i = ( i + 1 )
        set rawcodes[i] = 'u02I'
        // Medieval
        set i = ( i + 1 )
        set rawcodes[i] = 'u02L'
        // Murloc
        set i = ( i + 1 )
        set rawcodes[i] = 'u060'
        // Mushrooms
        set i = ( i + 1 )
        set rawcodes[i] = 'u046'
        // Naga (Original)
        set i = ( i + 1 )
        set rawcodes[i] = 'u06J'
        // Naga 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u03R'
        // Naga 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u00E'
        // Nordic
        set i = ( i + 1 )
        set rawcodes[i] = 'u03S'
        // Orc
        set i = ( i + 1 )
        set rawcodes[i] = 'u05T'
        // Orc Fort
        set i = ( i + 1 )
        set rawcodes[i] = 'u06O'
        // Pandaren
        set i = ( i + 1 )
        set rawcodes[i] = 'u02N'
        // Pirate
        set i = ( i + 1 )
        set rawcodes[i] = 'u06H'
        // Plants
        set i = ( i + 1 )
        set rawcodes[i] = 'u011'
        // Quilboar
        set i = ( i + 1 )
        set rawcodes[i] = 'u026'
        // Rohan
        set i = ( i + 1 )
        set rawcodes[i] = 'u063'
        // Rostrodle
        set i = ( i + 1 )
        set rawcodes[i] = 'u02Q'
        // Ruined 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u044'
        // Ruins
        set i = ( i + 1 )
        set rawcodes[i] = 'u00X'
        // Runes
        set i = ( i + 1 )
        set rawcodes[i] = 'u001'
        // Runic
        set i = ( i + 1 )
        set rawcodes[i] = 'u02M'
        // S&S Manor 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u008'
        // S&S Manor 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u009'
        // S&S Manor 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u00G'
        // S&S Manor 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u00L'
        // S&S Shire 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u05Y'
        // S&S Shire 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u05Z'
        // Statue 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u023'
        // Tableware
        set i = ( i + 1 )
        set rawcodes[i] = 'u007'
        // Undead
        set i = ( i + 1 )
        set rawcodes[i] = 'u00U'
        // Underwater
        set i = ( i + 1 )
        set rawcodes[i] = 'u06L'
        // Vampiric
        set i = ( i + 1 )
        set rawcodes[i] = 'u04O'
        // Village
        set i = ( i + 1 )
        set rawcodes[i] = 'u01O'
        // Walls 1
        set i = ( i + 1 )
        set rawcodes[i] = 'u02J'
        // Walls 2
        set i = ( i + 1 )
        set rawcodes[i] = 'u02K'
        // Wintergarde
        set i = ( i + 1 )
        set rawcodes[i] = 'u062'
        
        set LoP_DecoBuilders.AdvDecoLastIndex = i
        // ---------
        // End of Deco Creation
        // ---------
        set LoP_DecoBuilders.DecoLastIndex = i
        
        set i = 0
        loop
            exitwhen i > LoP_DecoBuilders.SpecialDecoLastIndex
            set reforgedRawcodes[i] = rawcodes[i]
            set i = i + 1
        endloop
        
        // ---------
        // Reforged Decos
        // ---------
        // Dalaran
        set reforgedRawcodes[i] = 'u07Q'
        // Human
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07M'
        // Market
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07R'
        // Night Elf
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07P'
        // Orc
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07N'
        // Plants 1
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07K'
        // Plants 2
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07I'
        // Rocks 1
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07L'
        // Rocks 2
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07J'
        // Undead
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u07O'
        // Walls
        set i = ( i + 1 )
        set reforgedRawcodes[i] = 'u083'
        
        set LoP_DecoBuilders.ReforgedDecoLastIndex = i
        
    endmethod
endmodule

struct LoP_DecoBuilders extends array

    static integer array rawcodes
    static integer array reforgedRawcodes

    static constant method operator SpecialDecoFirstIndex takes nothing returns integer
        return 0
    endmethod
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("SpecialDecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("BasicDecoFirstIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("BasicDecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("AdvDecoFirstIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("AdvDecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("DecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("ReforgedDecoLastIndex","integer")



    implement InitModule
endstruct

//Checks the deco counter for the player. If any counter is 0, create the missing deco.
public function CreateMissing takes player owner, real x, real y, group g, integer firstIndex, integer lastIndex, boolean reforged returns nothing
    local integer id

    loop
    exitwhen firstIndex > lastIndex
        if reforged then
            set id = LoP_DecoBuilders.reforgedRawcodes[firstIndex]
        else
            set id = LoP_DecoBuilders.rawcodes[firstIndex]
        endif
    
        if LoPHeader.CountPlayerUnitsOfType(owner, id) == 0 then
            if g == null then
                call CreateUnit(owner, id, x, y, bj_UNIT_FACING)
            else
                call GroupAddUnit(g, CreateUnit(owner, id, x, y, bj_UNIT_FACING))
            endif
        endif
        
        set firstIndex = firstIndex + 1
    endloop
endfunction

endlibrary