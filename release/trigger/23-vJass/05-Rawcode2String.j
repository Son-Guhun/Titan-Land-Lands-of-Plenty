library Rawcode2String requires TableStruct, StringHashEx
/*

    What are Rawcodes?
        Object ids in WC3 are four character codes which represent an integer. The value of each character is equal
    to its index in the ASCII table, and each represents a single byte of the 4 byte integer in a big-endian order.
    
    How to convert them?
        Example with rawcode 'Aa12':
        
         A       a       1       2
        065     097     049     050
        
        Since the representation is big-endian, the most significant byte is the first one, 'A'. As such, when
    converting to an integer, we must multiply the values by a power of 256 (as a single byte can represent
    a number from 0 to 255) accordingly.

        id = 256^3 * 65 + 256^2 * 97 + 256^1*49 + 256^0*50
        id = 16777216*65 + 65536*97 + 256*49 + 1*50
        id = 1096888626
        
________________________________________________________________
                            API
________________________________________________________________*/
//! novjass

// Converts from an alphanumeric four character string to an integer.
/* 
 - For strings shorter than 4 characters, 0 will be returned.
 - For strings longer than 4 characters, only the first four will be used.
 - Only alphanumeric strings will return valid results.
*/
function S2ID takes string source returns integer

// Converts an integer to an alphanumeric four character string.
/* 
 - For numbers in which a byte is not alphanumeric in the ASCII table, '_' will be used for that byte.
 - Example: ID2S(0) -> ID2S(000 000 000 000) -> "____" (as 000 has no alphanumeric representation, '_' is used)
 - Example: ID2S(1751530863) -> ID2S(104 102 061 111) -> "hf_o" (as 61 is '=' in the ASCII table, it is not alphanumeric and becomes '_')
*/
function ID2S takes integer source returns string


// Examples:
    ID2S(1751543663) -> "hfoo"
    S2ID("hfoo")     -> 1751543663
    
    // Special cases
    S2ID("hfoo123s") -> 1751543663 /* only first 4 characters are used */
    S2ID("h")        -> 0 /* length smaller than 4 */
    
    // Invalid cases
    S2ID("hf=o") -> // Invalid result, as the string contains an alphanumeric character.
    ID2S(0)      -> "____" // Invalid result, '_' is used where a non-alphanumeric byte was found.
//! endnovjass
/*_______________________________________________________________
                        Source Code
________________________________________________________________*/


private keyword Init

public struct Char extends array

    //! runtextmacro TableStruct_NewConstTableField("private", "ord")

    /*
    Generated with the following python code:
    
        numbers = "0123456789"
        upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        lower = upper.lower()
        ords = lambda string: [ord(c) for c in string]
        valid = set(ords(numbers+upper+lower))
        result = ''.join([chr(i) if i in valid else '_' for i in range(256)])
    */
    static method operator alphabet takes nothing returns string
        return "________________________________________________0123456789_______ABCDEFGHIJKLMNOPQRSTUVWXYZ______abcdefghijklmnopqrstuvwxyz_____________________________________________________________________________________________________________________________________"
    endmethod
    
    static method [] takes string char returns thistype
        return ord[StringHashEx(char)]
    endmethod
    
    method operator string takes nothing returns string
        return SubString(alphabet, this, this+1)
    endmethod
    
    implement Init
endstruct

function S2ID takes string source returns integer
    if StringLength(source) < 4 then  // string overflow safety check
        return 0
    endif
    return Char[SubString(source, 0, 1)]*16777216 + Char[SubString(source, 1, 2)]*65536 + Char[SubString(source, 2, 3)]*256 + Char[SubString(source, 3, 4)] 
endfunction

function ID2S takes integer source returns string
    return Char(ModuloInteger(source/16777216, 256)).string + Char(ModuloInteger(source/65536, 256)).string + Char(ModuloInteger(source/256, 256)).string + Char(ModuloInteger(source, 256)).string
endfunction

private module Init
    private static method onInit takes nothing returns nothing
        local integer i = 0
        local string char
        
        loop
        exitwhen i >= StringLength(alphabet)
            set char = SubString(alphabet, i, i+1)
            
            if char != "_" then
                set ord[StringHashEx(char)] = i
            endif
        
            set i = i + 1
        endloop
    endmethod
endmodule
    
endlibrary
