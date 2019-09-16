library LoPDeprecated requires TableStruct

private keyword InitModule

struct DeprecatedData extends array
    implement InitModule
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("equivalent", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("yawOffset", "real")
    
    static method isUnitTypeIdDeprecated takes DeprecatedData unitId returns boolean
        return unitId.equivalentExists()
    endmethod
    
    method hasYawOffset takes nothing returns boolean
        return yawOffsetExists()
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
    endmethod
endmodule

endlibrary
