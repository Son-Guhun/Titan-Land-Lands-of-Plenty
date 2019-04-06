library LoPDecoBuilders requires TableStruct
    
    struct LoP_DecoBuilders extends array
    
    static constant method operator SpecialDecoFirstIndex takes nothing returns integer
        return 0
    endmethod
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("SpecialDecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("BasicDecoFirstIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("BasicDecoLastIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("AdvDecoFirstIndex","integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("DecoLastIndex","integer")
    
    endstruct


    // The number of Deco Builders inside of the Special Deco Tent.
    constant function SpecialDecoTotal takes nothing returns integer
        return 2 // This is actually 1 less than the total to be in line with udg_System_DecoTotal
    endfunction
    
    globals
    
    
    endglobals

endlibrary

library LoPInitDecoBuilders requires LoPDecoBuilders
/*
    This library defines functions to initialize the values of the udg_DecoUnitTypes[] array, which
should contain the rawcodes of all existing Deco Builders, in alphabetical order. Special builders 
are listed first, though.

    It also defines functions to create the Deco Tents in the Titan Palace, which are dynamically
    generated.
*/


// The number of Basic Deco Builders



// This function is called in Init 0 seconds
function InitDecoTents takes nothing returns nothing
    local rect decoRect = gg_rct_Deco_Tents_Rect
    
    local real xStep = 256.
    local real yStep = 192.
    
    local real xMax = GetRectMaxX(decoRect) - xStep
    local real xMin = GetRectMinX(decoRect)
    local real yMax = GetRectMaxY(decoRect)
    local real yMin = GetRectMinY(decoRect)
    
    local real xStart = xMin + xStep/2.
    local real yStart = yMin + yStep/2.
    local real xCur = xStart
    local real yCur = yStart
        
    local unit decoTent = null
    local integer decoNumber = 0
    
    local integer i
    
    local integer decoTentCount = 1
    
    loop
    exitwhen decoNumber > SpecialDecoTotal()
        set decoTent = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n03H', xCur, yCur, bj_UNIT_FACING)
        call BlzSetUnitName(decoTent, "Deco Tent Special "+ I2S(decoTentCount))
        call SetUnitVertexColor(decoTent, 255, 165, 0, 255)
        
        set i = 0
        loop
        exitwhen i >= bj_MAX_STOCK_UNIT_SLOTS or decoNumber > SpecialDecoTotal()
            call AddUnitToStock(decoTent, udg_DecoUnitTypes[decoNumber], 1, 3)
            set i = i + 1
            set decoNumber = decoNumber + 1
        endloop
        
        set xCur = xCur + xStep
        if xCur > xMax then
            set yCur = yCur + yStep
            set xCur = xStart
        endif
        set decoTentCount = decoTentCount + 1

    endloop
    
    set decoTentCount = 1
    
    loop
    exitwhen decoNumber > udg_System_DecoTotal
        set decoTent = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n03H', xCur, yCur, bj_UNIT_FACING)
        call BlzSetUnitName(decoTent, "Deco Tent "+ I2S(decoTentCount))
        
        set i = 0
        loop
        exitwhen i >= bj_MAX_STOCK_UNIT_SLOTS or decoNumber > udg_System_DecoTotal
            call AddUnitToStock(decoTent, udg_DecoUnitTypes[decoNumber], 1, 3)
            set i = i + 1
            set decoNumber = decoNumber + 1
        endloop
        
        set xCur = xCur + xStep
        if xCur > xMax then
            set yCur = yCur + yStep
            set xCur = xStart
        endif
        set decoTentCount = decoTentCount + 1

    endloop
endfunction

// This function is called in Init Main
function InitDecoUnitTypeArray takes nothing returns nothing
    local integer i = 0
    // ---------
    // Special Decos
    // ---------
    // Units and Trees
    set udg_DecoUnitTypes[i] = 'u015'
    // Terrain
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02E'
    // Controller
    // set i = ( i + 1 )
    // set udg_DecoUnitTypes[i] = 'h0KD'
    // Docks
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u003'
    // Misc
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00W'
    
    
    // ---------
    // Basic Decos
    // ---------
    // Archways
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u014'
    // Bushes
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00A'
    // Camp
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u035'
    // City 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u016'
    // City 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u017'
    // City 3
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01T'
    // Corpses
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00N'
    // Crops
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00B'
    // Dungeon
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01P'
    // Effects
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u036'
    // Fire
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01C'
    // Furniture Deco
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03Q'
    // Gates
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00V'
    // Ice
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03P'
    // Rocks
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u013'
    // Seats
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01R'
    // Statue 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01N'
    // Statue 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u023'
    // Walls (Wood)
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u000'
    // Walls 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02J'
    // Walls 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02K'
    // Water
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00Z'
    // Webs
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02P'
    
    
    // Arabian 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02G'
    // Arabian 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02H'
    // Blacksmith
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01E'
    // Blocks
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03A'
    // Celtic
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u029'
    // Chaos
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u039'
    // Chess
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u027'
    // Dalaran
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02D'
    // Draenei
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02O'
    // Elves
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02A'
    // Fence
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03I'
    // Flags
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u005'
    // Floors
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02C'
    // Flowers 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u004'
    // Flowers 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u006'
    // Forsaken
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u025'
    // Goblin
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02R'
    // Gravestones
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02S'
    // Mansion
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02I'
    // Market
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01D'
    // Medieval 1
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01S'
    // Medieval 2
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02L'
    // Naga
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03R'
    // Nordic
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u03S'
    // Obelisks
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00Y'
    // Pandaren
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02N'
    // Quilboar
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u026'
    // Rostrodle
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02Q'
    // Ruined
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02T'
    // Ruins
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u00X'
    // Runes
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u001'
    // Runic
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u02M'
    // Trees
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01B'
    // Village
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u01O'
    // Walls (Icecrown)
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u011'
    // Walls (Ruins)
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u012'
    // Walls (Stone)
    set i = ( i + 1 )
    set udg_DecoUnitTypes[i] = 'u010'
    
    // End of Deco Creation
    set udg_System_DecoTotal = i
endfunction
endlibrary