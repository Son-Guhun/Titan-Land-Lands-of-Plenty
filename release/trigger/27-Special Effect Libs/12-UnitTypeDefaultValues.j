library UnitTypeDefaultValues requires TableStruct
/*
    Some unit types may have default scaling value, rgb or animation tags. In order for Unit2Effect
to work correctly, these values must be taken into account when converting a unit which hasn't had
these values altered by the UnitVisualMods library.

    The script that automatically generates definitions for this library can be found at:
        '_scripts/paste/getdecoproperties.py'
*/

private keyword InitModule

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
    
    implement InitModule
endstruct

private module InitModule

    // Paste inside the method below after running the python script.
    private static method onInit takes nothing returns nothing
        set UnitTypeDefaultValues('h02X').modelScale = 3.0
        set UnitTypeDefaultValues('h03L').modelScale = 2.0
        set UnitTypeDefaultValues('h04Z').modelScale = 10.0
        set UnitTypeDefaultValues('h05J').maxRoll = -90.0
        set UnitTypeDefaultValues('h077').modelScale = 2.0
        set UnitTypeDefaultValues('h0BE').red = 0
        set UnitTypeDefaultValues('h0BE').green = 0
        set UnitTypeDefaultValues('h0BE').blue = 0
        set UnitTypeDefaultValues('h0BG').red = 200
        set UnitTypeDefaultValues('h0BG').green = 200
        set UnitTypeDefaultValues('h0BG').blue = 200
        set UnitTypeDefaultValues('h0BH').modelScale = 3.0
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
        set UnitTypeDefaultValues('h0MF').maxRoll = -90.0
        set UnitTypeDefaultValues('h0MG').maxRoll = -90.0
        set UnitTypeDefaultValues('h15L').modelScale = 0.6
        set UnitTypeDefaultValues('h1DV').modelScale = 0.8
        set UnitTypeDefaultValues('h1DW').modelScale = 0.8
        set UnitTypeDefaultValues('h1E2').modelScale = 0.8
        set UnitTypeDefaultValues('h1E3').modelScale = 0.8
        set UnitTypeDefaultValues('h1E4').modelScale = 0.8
        set UnitTypeDefaultValues('h1E5').modelScale = 0.8
        set UnitTypeDefaultValues('h1I4').modelScale = 2.0
        set UnitTypeDefaultValues('h1K7').modelScale = 3.0
        set UnitTypeDefaultValues('h1K8').modelScale = 3.0
        set UnitTypeDefaultValues('h1K9').modelScale = 3.0
        set UnitTypeDefaultValues('h1KA').modelScale = 3.0
        set UnitTypeDefaultValues('h1KB').modelScale = 3.0
        set UnitTypeDefaultValues('h1KC').modelScale = 3.0
        set UnitTypeDefaultValues('h1M2').modelScale = 0.5
        set UnitTypeDefaultValues('h1M3').modelScale = 0.5
        set UnitTypeDefaultValues('h1M4').modelScale = 0.5
        set UnitTypeDefaultValues('h1M5').modelScale = 0.5
        set UnitTypeDefaultValues('h1M6').modelScale = 0.5
        set UnitTypeDefaultValues('h1M7').modelScale = 0.5
        set UnitTypeDefaultValues('h1M8').modelScale = 0.5
        set UnitTypeDefaultValues('h1MD').modelScale = 0.5
        set UnitTypeDefaultValues('h1ME').modelScale = 0.5
        set UnitTypeDefaultValues('h1MF').modelScale = 0.5
        set UnitTypeDefaultValues('h1MG').modelScale = 0.5
        set UnitTypeDefaultValues('h1MH').modelScale = 0.5
        set UnitTypeDefaultValues('h1MI').modelScale = 0.5
        set UnitTypeDefaultValues('h1MJ').modelScale = 0.5
        set UnitTypeDefaultValues('h1MK').modelScale = 0.5
        set UnitTypeDefaultValues('h1ML').modelScale = 0.5
        set UnitTypeDefaultValues('h1MM').modelScale = 0.5
        set UnitTypeDefaultValues('u02F').modelScale = 0.52
    endmethod
endmodule

endlibrary