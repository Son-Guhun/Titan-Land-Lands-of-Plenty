library AnyBase requires ConstTable, StringHashEx
/* Provides functionality to convert a number to a string in any base from 2 to 92. */

//! novjass
'                                        Documentation                                             '

/////////////
// Struct API
struct AnyBase extends array

    // Digits used for encoding
    static constant string digits = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[]{}()|/,.?!@#$%^&*'`+-=<>~:;_"
    
    // A table that maps hashes of each character to its index in AnyBase.digits
    static constant ConstTable values
    
    method encode takes integer x returns string
    method decode takes string  x returns integer
endstruct

/////////////
// Function API
function Int2Base takes integer base, integer x returns string

function Base2Int takes integer base, string x returns integer

/////////////
// Example usage
    AnyBase(16).decode("ff") -> 256
    AnyBase(2).encode(3) -> "11"
    Int2Base(8, 16) -> "20"
    Base2Int(8, "20") -> 16
    AnyBase.values[StringHash("9")] -> 9
    AnyBase.values[StringHash("A")] -> 10
'                                         Source Code                                              '
//! endnovjass

private keyword AnyBaseInit
struct AnyBase extends array
    private static key tab
    
    static constant method operator digits takes nothing returns string
        return "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[]{}()|/,.?!@#$%^&*'`+-=<>~:;_"
    endmethod
    
    static constant method operator values takes nothing returns ConstTable
        return tab
    endmethod
    
    method encode takes integer x returns string
        local string result = ""
        local integer index
        
        loop
        exitwhen x == 0

                set index = x - (x / this) * this
                set result = SubString(AnyBase.digits, index, index+1) + result
                set x = x / this
        endloop
        
        return result
    endmethod
    
    method decode takes string x returns integer
        local integer i = StringLength(x) - 1
        local integer pow = 1
        local integer result = 0
        
        loop
        exitwhen i < 0
            set result = result + AnyBase.values[StringHash(SubString(x, i, i+1))]*pow
            set pow = pow * this
            set i = i - 1
        endloop
        
        return result
    endmethod
    
    implement AnyBaseInit
endstruct
private module AnyBaseInit
    private static method onInit takes nothing returns nothing
        local integer i = StringLength(digits) - 1
        
        loop
        exitwhen i < 0
            set .values[StringHashEx(SubString(.digits, i, i+1))] = i
            set i = i - 1
        endloop
    endmethod
endmodule

function Int2Base takes integer base, integer x returns string
    return AnyBase(base).encode(x)
endfunction

function Base2Int takes integer base, string x returns integer
    return AnyBase(base).decode(x)
endfunction

endlibrary
