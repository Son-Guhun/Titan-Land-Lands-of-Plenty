library UnitTypeDefaultValues initializer onInit requires TableStruct

struct UnitTypeDefaultValues extends array
    
    //! runtextmacro TableStruct_NewPrimitiveField("modelScale","real")
    //! runtextmacro TableStruct_NewPrimitiveField("red","integer")
    //! runtextmacro TableStruct_NewPrimitiveField("green","integer")
    //! runtextmacro TableStruct_NewPrimitiveField("blue","integer")
    //! runtextmacro TableStruct_NewPrimitiveField("animProps","string")
    //! runtextmacro TableStruct_NewPrimitiveField("maxRoll","real")
    
    method hasModelScale takes nothing returns boolean
        return modelScaleExists()
    endmethod
    
    method hasRed takes nothing returns boolean
        return redExists()
    endmethod
    
    method hasGreen takes nothing returns boolean
        return greenExists()
    endmethod
    
    method hasBlue takes nothing returns boolean
        return blueExists()
    endmethod
    
    method hasAnimProps takes nothing returns boolean
        return animPropsExists()
    endmethod
    
    method hasMaxRoll takes nothing returns boolean
        return maxRollExists()
    endmethod
    
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        set UnitTypeDefaultValues('h02X').modelScale = 3.
        set UnitTypeDefaultValues('h03L').modelScale = 2.
        set UnitTypeDefaultValues('h04Z').modelScale = 10.
        set UnitTypeDefaultValues('h05J').maxRoll = -90.
        set UnitTypeDefaultValues('h077').modelScale = 2.
        set UnitTypeDefaultValues('h0BE').red = 0
        set UnitTypeDefaultValues('h0BE').green = 0
        set UnitTypeDefaultValues('h0BE').blue = 0
        set UnitTypeDefaultValues('h0BG').red = 200
        set UnitTypeDefaultValues('h0BG').green = 200
        set UnitTypeDefaultValues('h0BG').blue = 200
        set UnitTypeDefaultValues('h0BH').modelScale = 3.
        set UnitTypeDefaultValues('h0BN').animProps = "alternate"
        set UnitTypeDefaultValues('h0FF').modelScale = 0.8
        set UnitTypeDefaultValues('h0FI').modelScale = 0.8
        set UnitTypeDefaultValues('h0IB').modelScale = 1.2
        set UnitTypeDefaultValues('h0IC').modelScale = 1.2
        set UnitTypeDefaultValues('h0IX').modelScale = 0.52
        set UnitTypeDefaultValues('h0J3').modelScale = 0.5
        set UnitTypeDefaultValues('h0JA').modelScale = 0.5
        set UnitTypeDefaultValues('h0JB').modelScale = 0.5
        set UnitTypeDefaultValues('h0LG').animProps = "second"
        set UnitTypeDefaultValues('h0MF').maxRoll = -90.
        set UnitTypeDefaultValues('h0MG').maxRoll = -90.
        set UnitTypeDefaultValues('u00C').red = 150
        set UnitTypeDefaultValues('u00C').green = 100
        set UnitTypeDefaultValues('u00C').blue = 100
        set UnitTypeDefaultValues('u02F').modelScale = 0.52
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary