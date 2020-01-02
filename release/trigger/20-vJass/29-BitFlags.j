library BitFlags
/*
*   v1.0.0 - by Guhun
*
*
*   With patch 1.31, Blizzard introduced many new natives that function as flags in a a bit field,
* such as the meta keys in the oskeytype events. This library introduces utility functions that make
* code featuring boolean flags in bit fields much clearer. It also provides constants for all powers
* of 2 available (these can be used as actual flags for the bit field).
*
*/
//! novjass
'                                                                                                  '
'                                              API                                                 '

/*
    Structs
*/

// Holds constants that represent powers of 2. All of these constants will be inlined by JassHelper.
struct Pow2 extends array

    static constant n0 = 1
    static constant n1 = 2
    static constant n2 = 4
    ...
    static constant n30 = 1073741824
    static constant n31 = - 2147483648 $negative$

endstruct

/* 
    Functions
*/
$inlines$ -> "this means a function inlines, so only natives are actually called"

// Returns true if <field> contains all flags in <flags>.
function BitAll takes integer field, integer flags returns boolean

// Returns true if <field> contains at least one flag in <flags>.
$inlines$
function BitAny takes integer field, integer flags returns boolean

// Returns true if <field> contains no flags in <flags>. Equivalent to 'not BitAny(fields, flags)'.
$inlines$
function BitNone takes integer field, integer flags returns boolean

// Returns true if <field> contains at least one flag in <flags> but, not all of them.
function BitNotAll takes integer field, integer flags returns boolean

// Returns true if <field> contains only a single flag in <flags>.
function BitSingle takes integer field, integer flags returns boolean

// Counts the number of ones in the binary representation of <x>.
function BitCountOnes takes integer x returns integer

// Counts the number of zeroes in the binary representation of <x>.
function BitCountZeroes takes integer x returns integer

/* 
    Examples
*/
BitAll(Pow2.n2 + Pow2.n3 + Pow2.n5    ,  Pow2.n2 + Pow2.n3)           -> true
BitAll(Pow2.n2 + Pow2.n3 + Pow2.n5    ,  Pow2.n2 + Pow2.n3+Pow2.n4)   -> false

BitAny(Pow2.n2 + Pow2.n3 + Pow2.n5    ,  Pow2.n2 + Pow2.n3 + Pow2.n4) -> true
BitAny(Pow2.n2 + Pow2.n3 + Pow2.n5    ,  Pow2.n0)                     -> false

BitNotAll(Pow2.n2 + Pow2.n3 + Pow2.n5 ,  Pow2.n2 + Pow2.n3)           -> false
BitNotAll(Pow2.n2 + Pow2.n5           ,  Pow2.n2 + Pow2.n3)           -> true

BitSingle(Pow2.n2 + Pow2.n3 + Pow2.n5 ,  Pow2.n2 + Pow2.n3)           -> false
BitSingle(Pow2.n2 + Pow2.n3 + Pow2.n5 ,  Pow2.n5)                     -> true

BitCountOnes(Pow2.n2)                     -> 1
BitCountOnes(Pow2.n7 + Pow2.n10)          -> 2
BitCountOnes(Pow2.n2 + Pow2.n3 + Pow2.n5) -> 3

BitCountZeroes(0)                           -> 32
BitCountZeroes(Pow2.n2)                     -> 31
BitCountZeroes(Pow2.n7 + Pow2.n10)          -> 30
BitCountZeroes(Pow2.n2 + Pow2.n3 + Pow2.n5) -> 20
BitCountZeroes(-1)                          -> 0
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

//! textmacro BitFlags_Pow2 takes pow, value
    static constant method operator n$pow$ takes nothing returns integer
        return $value$
    endmethod
//! endtextmacro
struct Pow2 extends array
    //! runtextmacro BitFlags_Pow2("0","1")
    //! runtextmacro BitFlags_Pow2("1","2")
    //! runtextmacro BitFlags_Pow2("2","4")
    //! runtextmacro BitFlags_Pow2("3","8")
    //! runtextmacro BitFlags_Pow2("4","16")
    //! runtextmacro BitFlags_Pow2("5","32")
    //! runtextmacro BitFlags_Pow2("6","64")
    //! runtextmacro BitFlags_Pow2("7","128")
    //! runtextmacro BitFlags_Pow2("8","256")
    //! runtextmacro BitFlags_Pow2("9","512")
    //! runtextmacro BitFlags_Pow2("10","1024")
    //! runtextmacro BitFlags_Pow2("11","2048")
    //! runtextmacro BitFlags_Pow2("12","4096")
    //! runtextmacro BitFlags_Pow2("13","8192")
    //! runtextmacro BitFlags_Pow2("14","16384")
    //! runtextmacro BitFlags_Pow2("15","32768")
    //! runtextmacro BitFlags_Pow2("16","65536")
    //! runtextmacro BitFlags_Pow2("17","131072")
    //! runtextmacro BitFlags_Pow2("18","262144")
    //! runtextmacro BitFlags_Pow2("19","524288")
    //! runtextmacro BitFlags_Pow2("20","1048576")
    //! runtextmacro BitFlags_Pow2("21","2097152")
    //! runtextmacro BitFlags_Pow2("22","4194304")
    //! runtextmacro BitFlags_Pow2("23","8388608")
    //! runtextmacro BitFlags_Pow2("24","16777216")
    //! runtextmacro BitFlags_Pow2("25","33554432")
    //! runtextmacro BitFlags_Pow2("26","67108864")
    //! runtextmacro BitFlags_Pow2("27","134217728")
    //! runtextmacro BitFlags_Pow2("28","268435456")
    //! runtextmacro BitFlags_Pow2("29","536870912")
    //! runtextmacro BitFlags_Pow2("30","1073741824")
    //! runtextmacro BitFlags_Pow2("31","-2147483648")
endstruct

function BitAll takes integer field, integer flags returns boolean
    return BlzBitAnd(field, flags) == flags
endfunction

function BitAny takes integer field, integer flags returns boolean
    return BlzBitAnd(field, flags) != 0
endfunction

function BitNone takes integer field, integer flags returns boolean
    return BlzBitAnd(field, flags) == 0
endfunction

function BitNotAll takes integer field, integer flags returns boolean
    local integer x = BlzBitAnd(field, flags)
    return x != flags and x != 0
endfunction

function BitSingle takes integer field, integer flags returns boolean
    local integer x = BlzBitAnd(field, flags)
    return x==1 or (x!=0 and BlzBitAnd(x, x-1) == 0)
endfunction


//! textmacro BitCountStep takes step
    if Pow2.n$step$ > x then
        return count
    endif
    if BitAny(x, Pow2.n$step$) then
        set count = count + 1
    endif
//! endtextmacro
function BitCountOnes takes integer x returns integer
    local integer count = 0
     	
    if x < 0 then
        set count = count + 1
        set x = x - Pow2.n31
    endif
    
    //! runtextmacro BitCountStep("0")
    //! runtextmacro BitCountStep("1")
    //! runtextmacro BitCountStep("2")
    //! runtextmacro BitCountStep("3")
    //! runtextmacro BitCountStep("4")
    //! runtextmacro BitCountStep("5")
    //! runtextmacro BitCountStep("6")
    //! runtextmacro BitCountStep("7")
    //! runtextmacro BitCountStep("8")
    //! runtextmacro BitCountStep("9")
    //! runtextmacro BitCountStep("10")
    //! runtextmacro BitCountStep("11")
    //! runtextmacro BitCountStep("12")
    //! runtextmacro BitCountStep("13")
    //! runtextmacro BitCountStep("14")
    //! runtextmacro BitCountStep("15")
    //! runtextmacro BitCountStep("16")
    //! runtextmacro BitCountStep("17")
    //! runtextmacro BitCountStep("18")
    //! runtextmacro BitCountStep("19")
    //! runtextmacro BitCountStep("20")
    //! runtextmacro BitCountStep("21")
    //! runtextmacro BitCountStep("22")
    //! runtextmacro BitCountStep("23")
    //! runtextmacro BitCountStep("24")
    //! runtextmacro BitCountStep("25")
    //! runtextmacro BitCountStep("26")        
    //! runtextmacro BitCountStep("27")
    //! runtextmacro BitCountStep("28")
    //! runtextmacro BitCountStep("29")
    //! runtextmacro BitCountStep("30")
    
    return count
endfunction


function BitCountZeroes takes integer x returns integer
    return 32 - BitCountOnes(x)
endfunction
    
    
endlibrary