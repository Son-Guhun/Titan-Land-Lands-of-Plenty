library PlayerColorUtils
/**************************************************************
*   Compatible with:
*   v1.2.9 by TriggerHappy
*
*   Modified by:
*   Guhun
*
*   This is a lite version of PlayerUtils whose sole purpose is to define global variables that
*   store the local player and their id. It is a fully compatible subset of the PlayerUtils API.
*
*
*   Struct API
*   -------------------
*     struct User
*
*       static method fromIndex takes integer i returns User
*       static method fromLocal takes nothing returns User
*
*       static method operator []    takes integer id returns User
*
*       method toPlayer takes nothing returns player
*
*       readonly static player Local
*       readonly static integer LocalId
*       readonly player handle
*       readonly integer id
*
**************************************************************/

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
        //! runtextmacro PlayerUtils_SetColors("0", "ff", "fc", "01")
        //! runtextmacro PlayerUtils_SetColors("0", "fe", "8a", "0e")
        //! runtextmacro PlayerUtils_SetColors("0", "20", "c0", "00")
        //! runtextmacro PlayerUtils_SetColors("0", "e5", "5b", "b0")
        //! runtextmacro PlayerUtils_SetColors("0", "85", "96", "97")
        //! runtextmacro PlayerUtils_SetColors("0", "7e", "bf", "f1")
        //! runtextmacro PlayerUtils_SetColors("0", "10", "62", "46")
        //! runtextmacro PlayerUtils_SetColors("0", "4e", "2a", "04")
       
        if (bj_MAX_PLAYERS > 12) then
            //! runtextmacro PlayerUtils_SetColors("0", "9b", "00", "00")
            //! runtextmacro PlayerUtils_SetColors("0", "00", "00", "c3")
            //! runtextmacro PlayerUtils_SetColors("0", "00", "ea", "ff")
            //! runtextmacro PlayerUtils_SetColors("0", "be", "00", "fe")
            //! runtextmacro PlayerUtils_SetColors("0", "eb", "cd", "87")
            //! runtextmacro PlayerUtils_SetColors("0", "f8", "a4", "8b")
            //! runtextmacro PlayerUtils_SetColors("0", "bf", "ff", "80")
            //! runtextmacro PlayerUtils_SetColors("0", "dc", "b9", "eb")
            //! runtextmacro PlayerUtils_SetColors("0", "28", "28", "28")
            //! runtextmacro PlayerUtils_SetColors("0", "eb", "f0", "ff")
            //! runtextmacro PlayerUtils_SetColors("0", "00", "78", "1e")
            //! runtextmacro PlayerUtils_SetColors("0", "a4", "6f", "33")
        endif
        
    endmethod
endmodule


endlibrary