library LoPDeprecated requires TableStruct
/*
    This library is used by the Save System in order to load deprecated units as their replacements.


*/

private keyword InitModule

struct DeprecatedData extends array
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("equivalent", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("yawOffset", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("animTags", "string")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("scale", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("roll", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("pitch", "real")
    
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
    
    method hasRoll takes nothing returns boolean
        return rollExists()
    endmethod
    
    method hasPitch takes nothing returns boolean
        return pitchExists()
    endmethod
    
    implement InitModule
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        local DeprecatedData unitType
        
        set unitType = 'h0MF'
        set unitType.equivalent = 'h0MB'
        set unitType.roll = 90.
        
        set unitType = 'h0MG'
        set unitType.equivalent = 'h0MC'
        set unitType.roll = 90.
        
        set unitType = 'h05J'
        set unitType.equivalent = 'h05I'
        set unitType.roll = 90.
        set unitType.pitch = 90.
    endmethod
endmodule

endlibrary
