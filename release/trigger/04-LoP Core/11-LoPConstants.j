/*
    USE_NAMESPACE_X pattern:
    
        Each library X defines a textmacro called USE_NAMESPACE_X(). This textmacro generates definitions
    for the public globals and functions defined in that library.  When this textmacro is used inside
    another library or in a scope, then the public members of that library can be called without using
    the library's prefix.

*/
library LoPConstants requires DECO, POWER, HERO
    // This library can be used to avoid requiring multiple constant libraries.
endlibrary

library DECO

    scope ABIL
        /* Constants for Decoration Ability rawcodes. */
        
        //! textmacro USE_NAMESPACE_DECO_ABIL
        globals
            public constant integer CONTROLLER = 'h0KD'
            
            public constant integer MOVE_UP = 'A032'
            public constant integer MOVE_LEFT = 'A02Y'
            public constant integer MOVE_RIGHT = 'A02Z'
            public constant integer MOVE_DOWN = 'A031'
            
            public constant integer MOVE = 'A037'
            
            public constant integer SUICIDE = 'A0B7'
            public constant integer FACE = 'A00T'
            public constant integer COPY = 'A012'
            public constant integer ROTATE = 'A011'
            
            public constant integer UPGRADE_PREV = 'A048'
            public constant integer UPGRADE_NEXT = 'A01T'
            
            public constant integer GATE_OPEN = 'A0B3'
            public constant integer GATE_CLOSE = 'A0B5'

            public constant integer PATHING_ON = 'A069'
            public constant integer PATHING_OFF = 'A068'
        endglobals
        //! endtextmacro
        

        //! runtextmacro USE_NAMESPACE_DECO_ABIL()
    endscope
    
endlibrary

/* Unit Constants
    
    These libraries define constants that represent pre-placed units in the map.
*/

library POWER
    /* Constants for Titan Powers. */

    //! textmacro USE_NAMESPACE_POWER
    public function INVULNERABILITY takes nothing returns unit
        return gg_unit_e00B_0405
    endfunction
    
    public function VULNERABILITY takes nothing returns unit
        return gg_unit_e00A_0411
    endfunction
    
    public function KILL takes nothing returns unit
        return gg_unit_e008_0406
    endfunction
    
    public function LEVEL takes nothing returns unit
        return gg_unit_e009_0407
    endfunction
    
    public function DELEVEL takes nothing returns unit
        return gg_unit_e00C_0408
    endfunction
    
    public function REMOVE takes nothing returns unit
        return gg_unit_e007_0410
    endfunction
    //! endtextmacro
    
    //! runtextmacro USE_NAMESPACE_POWER()
endlibrary

library HERO
    /* Constants for Cosmosis and Angel of Creation */

    //! textmacro USE_NAMESPACE_HERO
    public function COSMOSIS takes nothing returns unit
        return gg_unit_H00V_0359
    endfunction
    
    public function CREATOR takes nothing returns unit
        return gg_unit_H00S_0141
    endfunction
    //! endtextmacro

    //! runtextmacro USE_NAMESPACE_HERO()
endlibrary
