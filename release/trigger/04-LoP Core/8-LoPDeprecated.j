library LoPDeprecated requires TableStruct

private keyword InitModule

struct DeprecatedData extends array
    implement InitModule
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("equivalent", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("yawOffset", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("animTags", "string")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("scale", "real")
    
    static method isUnitTypeIdDeprecated takes DeprecatedData unitId returns boolean
        return unitId.equivalentExists()
    endmethod
    
    method hasYawOffset takes nothing returns boolean
        return yawOffsetExists()
    endmethod
    
    method hasAnimTags takes nothing returns boolean
        return animTagsExists()
    endmethod
    
    method hasScale takes nothing returns boolean
        return scaleExists()
    endmethod
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        local DeprecatedData unitType
        
        // Icecrown Walls
        set unitType = 'h000' // --
        set unitType.equivalent = 'h01W'
        set unitType = 'h007' // /
        set unitType.equivalent = 'h01X'
        set unitType = 'h008' // \
        set unitType.equivalent = 'h01X'
        set unitType.yawOffset = 90.
        set unitType = 'h01Y' // \ (NT)
        set unitType.equivalent = 'h01X'
        set unitType.yawOffset = 90.
        set unitType = 'h006' // |
        set unitType.equivalent = 'h01W'
        set unitType.yawOffset = 90.
        set unitType = 'h01Z' // | (NT)
        set unitType.equivalent = 'h01W'
        set unitType.yawOffset = 90.
        
        // Ruins Walls
        set unitType = 'h028' // --
        set unitType.equivalent = 'h024'
        set unitType = 'h021' // /
        set unitType.equivalent = 'h029'
        set unitType = 'h026' // \
        set unitType.equivalent = 'h029'
        set unitType.yawOffset = 90.
        set unitType = 'h02A' // \ (NT)
        set unitType.equivalent = 'h029'
        set unitType.yawOffset = 90.
        set unitType = 'h027' // |
        set unitType.equivalent = 'h024'
        set unitType.yawOffset = 90.
        set unitType = 'h02B' // | (NT)
        set unitType.equivalent = 'h024'
        set unitType.yawOffset = 90.

        // Stone Walls
        set unitType = 'h020' // --
        set unitType.equivalent = 'h01S'
        set unitType = 'h025' // /
        set unitType.equivalent = 'h01T'
        set unitType = 'h022' // \
        set unitType.equivalent = 'h01T'
        set unitType.yawOffset = 90.
        set unitType = 'h01U' // \ (NT)
        set unitType.equivalent = 'h01T'
        set unitType.yawOffset = 90.
        set unitType = 'h01V' // |
        set unitType.equivalent = 'h01S'
        set unitType.yawOffset = 90.
        set unitType = 'h023' // | (NT)
        set unitType.equivalent = 'h01S'
        set unitType.yawOffset = 90.
        
        // Wood Walls
        set unitType = 'h030' // --
        set unitType.equivalent = 'h034'
        set unitType = 'h031' // /
        set unitType.equivalent = 'h035'
        set unitType = 'h032' // \
        set unitType.equivalent = 'h035'
        set unitType.yawOffset = 90.
        set unitType = 'h036' // \ (NT)
        set unitType.equivalent = 'h035'
        set unitType.yawOffset = 90.
        set unitType = 'h033' // |
        set unitType.equivalent = 'h034'
        set unitType.yawOffset = 90.
        set unitType = 'h037' // | (NT)
        set unitType.equivalent = 'h034'
        set unitType.yawOffset = 90.
        

        // Fant Env Small Rocks
        set unitType = 'h0VI' // 2
        set unitType.equivalent = 'h0VL'
        set unitType = 'h0VJ' // 3
        set unitType.equivalent = 'h0VM'
        
        // Human Town Structures
        set unitType = 'hkee' // Castle
        set unitType.equivalent = 'htow'
        set unitType.animTags = "first"
        set unitType = 'hcas' // Keep
        set unitType.equivalent = 'htow'
        set unitType.animTags = "second"
        
        set unitType = 'hgtw' // Guard Tower
        set unitType.equivalent = 'hwtw'
        set unitType.animTags = "first"
        set unitType = 'hctw' // Cannon Tower
        set unitType.equivalent = 'hwtw'
        set unitType.animTags = "second"
        set unitType = 'hatw' // Arcane Tower
        set unitType.equivalent = 'hwtw'
        set unitType.animTags = "third"
        
        
        // Orc Town Halls
        set unitType = 'ogre' // 2
        set unitType.equivalent = 'h176'
        set unitType = 'ostr' // 2
        set unitType.equivalent = 'h176'
        set unitType.animTags = "first"
        set unitType = 'ofrt' // 3
        set unitType.equivalent = 'h176'
        set unitType.animTags = "second"
        
        // Temple of Tides
        set unitType = 'nntt'
        set unitType.equivalent = 'h0PE'
        set unitType.animTags = "first"
        
        // Removed Town Halls
        set unitType = 'h12K' // Lizardman Village
        set unitType.equivalent = 'h11T'
        set unitType = 'o02U' // Centaur Main Hut
        set unitType.equivalent = 'nct2'
        set unitType = 'o00I' // Troll Main Hut
        set unitType.equivalent = 'h17C'
        set unitType = 'ogre' // Great Hall
        set unitType.equivalent = 'h176'
        set unitType = 'h004' // Dwarven Temple
        set unitType.equivalent = 'hbla'
        set unitType = 'o00L' // Fel Great Hall
        set unitType.equivalent = 'h176'
        set unitType = 'o01Z' // Tauren Main Hut
        set unitType.equivalent = 'h176'
        set unitType = 'u04K' // Cultist Necropolis
        set unitType.equivalent = 'h165'
        set unitType = 'h0ZZ' // Worgen Manor
        set unitType.equivalent = 'htow'
        set unitType = 'u047' // Faceless Aspirant Spire
        set unitType.equivalent = 'u04D'
        
    endmethod
endmodule

endlibrary
