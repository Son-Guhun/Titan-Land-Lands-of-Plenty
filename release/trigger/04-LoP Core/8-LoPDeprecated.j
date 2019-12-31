library LoPDeprecated requires TableStruct

private keyword InitModule

struct DeprecatedData extends array
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
    
    implement InitModule
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        local DeprecatedData unitType
        
        
    endmethod
endmodule

endlibrary
