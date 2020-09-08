library PlayerColorUtils

private keyword Init

struct UserColor extends array
    
    readonly string hex
    readonly integer red
    readonly integer blue
    readonly integer green

    implement Init
endstruct

private module Init
    private static method onInit takes nothing returns nothing
        //! textmacro PlayerUtils_SetColors takes id, r, g, b
            set UserColor($id$).hex   = "|cff$r$$g$$b$"
            set UserColor($id$).red   = 0x$r$
            set UserColor($id$).green = 0x$g$
            set UserColor($id$).blue  = 0x$b$
        //! endtextmacro

        //! runtextmacro PlayerUtils_SetColors("0", "ff", "03", "03")
        //! runtextmacro PlayerUtils_SetColors("1", "00", "42", "ff")
        //! runtextmacro PlayerUtils_SetColors("2", "1c", "e6", "b9")
        //! runtextmacro PlayerUtils_SetColors("3", "54", "00", "81")
        //! runtextmacro PlayerUtils_SetColors("4", "ff", "fc", "01")
        //! runtextmacro PlayerUtils_SetColors("5", "fe", "8a", "0e")
        //! runtextmacro PlayerUtils_SetColors("6", "20", "c0", "00")
        //! runtextmacro PlayerUtils_SetColors("7", "e5", "5b", "b0")
        //! runtextmacro PlayerUtils_SetColors("8", "85", "96", "97")
        //! runtextmacro PlayerUtils_SetColors("9", "7e", "bf", "f1")
        //! runtextmacro PlayerUtils_SetColors("10", "10", "62", "46")
        //! runtextmacro PlayerUtils_SetColors("11", "4e", "2a", "04")
       
        if (bj_MAX_PLAYERS > 12) then
            //! runtextmacro PlayerUtils_SetColors("12", "9b", "00", "00")
            //! runtextmacro PlayerUtils_SetColors("13", "00", "00", "c3")
            //! runtextmacro PlayerUtils_SetColors("14", "00", "ea", "ff")
            //! runtextmacro PlayerUtils_SetColors("15", "be", "00", "fe")
            //! runtextmacro PlayerUtils_SetColors("16", "eb", "cd", "87")
            //! runtextmacro PlayerUtils_SetColors("17", "f8", "a4", "8b")
            //! runtextmacro PlayerUtils_SetColors("18", "bf", "ff", "80")
            //! runtextmacro PlayerUtils_SetColors("19", "dc", "b9", "eb")
            //! runtextmacro PlayerUtils_SetColors("20", "28", "28", "28")
            //! runtextmacro PlayerUtils_SetColors("21", "eb", "f0", "ff")
            //! runtextmacro PlayerUtils_SetColors("22", "00", "78", "1e")
            //! runtextmacro PlayerUtils_SetColors("23", "a4", "6f", "33")
        endif
        
    endmethod
endmodule


endlibrary