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
            // Black Empire
            set i = ( i + 1 )
            set rawcodes[i] = 'u00T'
            // Blacksmith
            set i = ( i + 1 )
            set rawcodes[i] = 'u01E'
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
            // Chess
            set i = ( i + 1 )
            set rawcodes[i] = 'u027'
            // Dalaran
            set i = ( i + 1 )
            set rawcodes[i] = 'u02D'
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
            // Gurubashi
            set i = ( i + 1 )
            set rawcodes[i] = 'u00O'
            // Hellfire Citadel
            set i = ( i + 1 )
            set rawcodes[i] = 'u04W'
            // Huts
            set i = ( i + 1 )
            set rawcodes[i] = 'u002'
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
            // Mushrooms
            set i = ( i + 1 )
            set rawcodes[i] = 'u046'
            // NPC
            set i = ( i + 1 )
            set rawcodes[i] = 'u048'
            // Naga 1
            set i = ( i + 1 )
            set rawcodes[i] = 'u03R'
            // Naga 2
            set i = ( i + 1 )
            set rawcodes[i] = 'u00E'
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
            // Ruined
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
            // Trees
            set i = ( i + 1 )
            set rawcodes[i] = 'u01B'
            // Vampiric
            set i = ( i + 1 )
            set rawcodes[i] = 'u04O'
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