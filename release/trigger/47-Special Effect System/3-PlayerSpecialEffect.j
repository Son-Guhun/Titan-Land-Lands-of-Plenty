library PlayerSpecialEffect requires SpecialEffect

module PlayerSpecialEffectModule
    // Use getter/setter to make it clear that null is invalid parameter
    //! runtextmacro HashStruct_NewPrimitiveGetterSetter("Owner","player")
endmodule

struct PlayerSpecialEffect extends array
    implement SpecialEffectModule
    implement PlayerSpecialEffectModule
    implement SpecialEffectGetDestroyMethods
endstruct

endlibrary
