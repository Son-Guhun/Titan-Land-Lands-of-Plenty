library UnitSpecialEffect requires SpecialEffect

module UnitSpecialEffectModule
    //! runtextmacro HashStruct_NewPrimitiveField("unitType","integer")

    method isAttached takes nothing returns boolean
        return .unitType_exists()
    endmethod
endmodule

struct UnitSpecialEffect extends array
    implement SpecialEffectModule
    implement UnitSpecialEffectModule
    implement SpecialEffectGetDestroyMethods
endstruct

endlibrary
