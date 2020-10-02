library Rawcode2String requires TableStruct, StringHashEx

private keyword Init

public struct Char extends array

    //! runtextmacro TableStruct_NewConstTableField("private", "ord")

    /*
    Generated with the following python code:
    
        numbers = "0123456789"
        upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        lower = upper.lower()
        ords = lambda string: [ord(c) for c in string]
        valid = set(ords(numbers) + ords(upper) + ords(lower))
        result = str([chr(i) if i in valid else '_' for i in range(256)])
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
