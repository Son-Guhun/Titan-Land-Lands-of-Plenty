library LoPDecoBuilders requires TableStruct
    /*
    This library defines functions to initialize the values of the rawcodes[] array, which
should contain the rawcodes of all existing Deco Builders, in alphabetical order. Special builders 
are listed first, though.
*/
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
            // Fire
            set i = ( i + 1 )
            set rawcodes[i] = 'u01C'
            // Furniture Deco
            set i = ( i + 1 )
            set rawcodes[i] = 'u03Q'
            // Gates
            set i = ( i + 1 )
            set rawcodes[i] = 'u00V'
            // Ice
            set i = ( i + 1 )
            set rawcodes[i] = 'u03P'
            // Rocks
            set i = ( i + 1 )
            set rawcodes[i] = 'u013'
            // Seats
            set i = ( i + 1 )
            set rawcodes[i] = 'u01R'
            // Statue 1
            set i = ( i + 1 )
            set rawcodes[i] = 'u01N'
            // Walls (Wood)
            set i = ( i + 1 )
            set rawcodes[i] = 'u000'
            // Walls 1
            set i = ( i + 1 )
            set rawcodes[i] = 'u02J'
            // Walls 2
            set i = ( i + 1 )
            set rawcodes[i] = 'u02K'
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
            // Blacksmith
            set i = ( i + 1 )
            set rawcodes[i] = 'u01E'
            // Blocks
            set i = ( i + 1 )
            set rawcodes[i] = 'u03A'
            // Celtic
            set i = ( i + 1 )
            set rawcodes[i] = 'u029'
            // Chaos
            set i = ( i + 1 )
            set rawcodes[i] = 'u039'
            // Chess
            set i = ( i + 1 )
            set rawcodes[i] = 'u027'
            // Dalaran
            set i = ( i + 1 )
            set rawcodes[i] = 'u02D'
            // Draenei
            set i = ( i + 1 )
            set rawcodes[i] = 'u02O'
            // Elves
            set i = ( i + 1 )
            set rawcodes[i] = 'u02A'
            // Fence
            set i = ( i + 1 )
            set rawcodes[i] = 'u03I'
            // Flags
            set i = ( i + 1 )
            set rawcodes[i] = 'u005'
            // Floors
            set i = ( i + 1 )
            set rawcodes[i] = 'u02C'
            // Flowers 1
            set i = ( i + 1 )
            set rawcodes[i] = 'u004'
            // Flowers 2
            set i = ( i + 1 )
            set rawcodes[i] = 'u006'
            // Forsaken
            set i = ( i + 1 )
            set rawcodes[i] = 'u025'
            // Goblin
            set i = ( i + 1 )
            set rawcodes[i] = 'u02R'
            // Gravestones
            set i = ( i + 1 )
            set rawcodes[i] = 'u02S'
            // Mansion
            set i = ( i + 1 )
            set rawcodes[i] = 'u02I'
            // Market
            set i = ( i + 1 )
            set rawcodes[i] = 'u01D'
            // Medieval 1
            set i = ( i + 1 )
            set rawcodes[i] = 'u01S'
            // Medieval 2
            set i = ( i + 1 )
            set rawcodes[i] = 'u02L'
            // Naga
            set i = ( i + 1 )
            set rawcodes[i] = 'u03R'
            // Nordic
            set i = ( i + 1 )
            set rawcodes[i] = 'u03S'
            // Obelisks
            set i = ( i + 1 )
            set rawcodes[i] = 'u00Y'
            // Pandaren
            set i = ( i + 1 )
            set rawcodes[i] = 'u02N'
            // Quilboar
            set i = ( i + 1 )
            set rawcodes[i] = 'u026'
            // Rostrodle
            set i = ( i + 1 )
            set rawcodes[i] = 'u02Q'
            // Ruined
            set i = ( i + 1 )
            set rawcodes[i] = 'u02T'
            // Ruins
            set i = ( i + 1 )
            set rawcodes[i] = 'u00X'
            // Runes
            set i = ( i + 1 )
            set rawcodes[i] = 'u001'
            // Runic
            set i = ( i + 1 )
            set rawcodes[i] = 'u02M'
            // Statue 2
            set i = ( i + 1 )
            set rawcodes[i] = 'u023'
            // Trees
            set i = ( i + 1 )
            set rawcodes[i] = 'u01B'
            // Village
            set i = ( i + 1 )
            set rawcodes[i] = 'u01O'
            // Walls (Icecrown)
            set i = ( i + 1 )
            set rawcodes[i] = 'u011'
            // Walls (Ruins)
            set i = ( i + 1 )
            set rawcodes[i] = 'u012'
            // Walls (Stone)
            set i = ( i + 1 )
            set rawcodes[i] = 'u010'
            
            set LoP_DecoBuilders.AdvDecoLastIndex = i
            // ---------
            // End of Deco Creation
            // ---------
            set LoP_DecoBuilders.DecoLastIndex = i
        endmethod
    endmodule
    
    struct LoP_DecoBuilders extends array
    
        static integer array rawcodes
    
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


    
        implement InitModule
    endstruct
    


endlibrary

library LoPInitDecoTents requires LoPDecoBuilders
/*
    It also defines functions to create the Deco Tents in the Titan Palace, which are dynamically
    generated.
*/
    globals
        constant integer Special_RED = 255
        constant integer Special_GREEN = 165
        constant integer Special_BLUE = 0
        constant integer Special_ALPHA = 255
        
        constant integer Basic_RED = 255
        constant integer Basic_GREEN = 255
        constant integer Basic_BLUE = 255
        constant integer Basic_ALPHA = 255
        
        constant integer Adv_RED = 255
        constant integer Adv_GREEN = 0
        constant integer Adv_BLUE = 0
        constant integer Adv_ALPHA = 255
    endglobals

// This function is called in Init 0 seconds (to reduce loading time)
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
    
    local integer decoTentCount
    
    //! textmacro DecoBuilders_MakeTents takes name
    set decoTentCount = 1
    loop
    exitwhen decoNumber > LoP_DecoBuilders.$name$DecoLastIndex
        set decoTent = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n03H', xCur, yCur, bj_UNIT_FACING)
        call BlzSetUnitName(decoTent, "Deco Tent $name$ "+ I2S(decoTentCount))
        call SetUnitVertexColor(decoTent, $name$_RED, $name$_GREEN, $name$_BLUE, $name$_ALPHA)
        
        set i = 0
        loop
        exitwhen i >= bj_MAX_STOCK_UNIT_SLOTS or decoNumber > LoP_DecoBuilders.$name$DecoLastIndex
            call AddUnitToStock(decoTent, LoP_DecoBuilders.rawcodes[decoNumber], 1, 3)
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
    //! endtextmacro
    
    //! runtextmacro DecoBuilders_MakeTents("Special")
    //! runtextmacro DecoBuilders_MakeTents("Basic")
    //! runtextmacro DecoBuilders_MakeTents("Adv")
endfunction


endlibrary