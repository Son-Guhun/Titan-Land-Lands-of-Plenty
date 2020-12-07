////////////////////////////////////////////////////////////////////////////////////////////////////
// Guhun's MUI Engine version 3.0.0
library GMUI
/*
    GMUI is a library that provides hashtable-based allocation for structs. The advantage of using
hashtables is that, with only a few functions and a global, allocation can be provided for any arbitrary
number of structs.

    Recycle Keys:
        Whenver creating a new ID with GMUI, or recycling an ID, one must pass a recycle key. A recycle
    key is basically a unique ID pool. For example, if I generate an ID for recycle key X, I cannot
    generate that same ID for X until I recycle it. However, if I use a different recycle key Y, then
    a call to GMUI_GetIndex may return ID, as it is unused for Y.
    
    Generic Recycle Key:
        For Hashtable indexing, which can handle up to 2^31 - 1 instances, you will realistically only
    ever need 1 recycle key. Therefore the system provides a constant GENERIC_KEY which can be used
    for any purpose in which you won't need a unique recycle key. Using this generic key is not
    recommended if you intend to use the generated IDs as array indices, as those are limited to 2^15
    instances.

===========
Documentation
===========

Functions:

    integer GMUI_GetIndex(integer recycleKey)  -> Gets a new unique ID from the given recycle key.
    nothing GMUI_RecycleIndex(integer recycleKey, integer instance)  -> Recycles an ID for the given recycle key.

Modules:
    GMUIAllocatorMethods  -> defines allocate() and deallocate() using GMUI_GetIndex and GMUI_RecycleIndex.
    .
    . To use this module, the struct must define a static method called RECYCLE_KEY() that returns an integer.
    
    . These modules should be called inside the create/destroy methods. They inline the GMUI functions and set/recycle 'this'.
    . They also use the type's RECYCLE_KEY() static method.
    .
    . GMUI_allocate_this
    . GMUI_deallocate_this
    
    
    GMUINewRecycleKey  -> Defines RECYCLE_KEY() as a new recycle key, for use with the modules above.
    GMUIUseGenericKey  -> Defines RECYCLE_KEY() as the generic recycle key, for use with the modules above.
    
    
Macros:
    GMUI_GetIndex(var_name,recycle_key)  -> inlines GMUI_GetIndex
    
    GMUI_RecycleIndex(var_name,recycle_key)  -> inlines GMUI_RecycleIndex

*/
////////////////////////////////////////////////////////////////////////////////////////////////////

globals

    public constant integer GENERIC_KEY = 0
    public hashtable hashTable = InitHashtable()
endglobals

// Textmacros

// Sets the variable "var_name" to a new index of the specified recycle key. "var_name" must be a variable or array index (array[i]). 
//! textmacro GMUI_GetIndex takes var_name,recycle_key
    set $var_name$ = LoadInteger(hashTable, $recycle_key$, 0)

    if not HaveSavedInteger(hashTable, $recycle_key$, $var_name$) then
        if $var_name$ == 0 then  // This small line guarantees that intializing a RECYCLE_KEY is not needed.
            set $var_name$ = 1
        endif
        call SaveInteger(hashTable, $recycle_key$, 0, $var_name$ + 1)
    else
        call SaveInteger(hashTable, $recycle_key$, 0, LoadInteger(hashTable, $recycle_key$, $var_name$))
        call RemoveSavedInteger(hashTable, $recycle_key$, $var_name$)
    endif
    
    call SaveInteger(hashTable, $recycle_key$, $var_name$, -1)
//! endtextmacro

// Recycles the value of variable "var_name" in the specified recycle key. Does not alter "var_name".
//! textmacro GMUI_RecycleIndex takes var_name,recycle_key
    if LoadInteger(hashTable, $recycle_key$, $var_name$) == -1 then
        if $var_name$ > 0 then  // Do not free a nil value
            call SaveInteger(hashTable, $recycle_key$, $var_name$, LoadInteger(hashTable, $recycle_key$, 0))
            call SaveInteger(hashTable, $recycle_key$, 0, $var_name$)
        else
            call BJDebugMsg("|cffff0000GMUI Error:|r Tried to free a negative or null index.")
        endif
    else
        call BJDebugMsg("|cffff0000GMUI Error:|r Tried to free an unused index (or double-free).")
    endif
//! endtextmacro


// Functions

//This function generates an instance number for a RecycleKey (using textmacro GMUI_GetIndex)
function GMUI_GetIndex takes integer recycleKey returns integer
    local integer instance
    
    //! runtextmacro GMUI_GetIndex("instance","recycleKey")
    return instance
endfunction


//This function recycles an instance number for a RecycleKey (using textmacro GMUI_RecycleIndex)
function GMUI_RecycleIndex takes integer recycleKey, integer instance returns nothing
    //! runtextmacro GMUI_RecycleIndex("instance","recycleKey")
endfunction

// Modules

// To implement these modules, the struct must have a method with the following declaration:
/*
[private] constant method RECYCLE_KEY takes nothing returns integer
*/
// The RECYCLE_KEY() method must return a global 'key' variable, which is the recycle key which will be
// used when allocating new struct instances.


// Implement this module in the body of a struct to generate allocate() and deallocate() methods. 
/*
    private method allocate takes nothing returns thistype
        return GMUI_GetIndex(thistype.RECYCLE_KEY())
    endmethod
    
    private method deallocate takes nothing returns nothing
        call GMUI_RecycleIndex(thistype.RECYCLE_KEY(), this)
    endmethod
*/
module GMUIAllocatorMethods

    static method allocate takes nothing returns thistype
        return GMUI_GetIndex(thistype.RECYCLE_KEY())
    endmethod
    
    method deallocate takes nothing returns nothing
        call GMUI_RecycleIndex(thistype.RECYCLE_KEY(), this)
    endmethod

endmodule

module GMUINewRecycleKey
    private static key _recycleKey
    
    static constant method RECYCLE_KEY takes nothing returns integer
        return _recycleKey
    endmethod
endmodule

module GMUIUseGenericKey
    static constant method RECYCLE_KEY takes nothing returns integer
        return GENERIC_KEY
    endmethod
endmodule

// Inlined allocators
//
// For those who need SPEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEED
//
// These modules are not implemented on the body of a struct, but inside the create() and destroy() methods.
//
//
// module GMUI_allocate_this => runs the GMUI_Get_Index textmacro with args: "this" and "thistype.RECYCKE_KEY()"
// module GMUI_deallocate_this => runs the GMUI_Recycle_Index textmacro with args: "this" and "thistype.RECYCKE_KEY()"
//
module GMUI_allocate_this
    //! runtextmacro GMUI_GetIndex("this","thistype.RECYCLE_KEY()")
endmodule

module GMUI_deallocate_this
    //! runtextmacro GMUI_RecycleIndex("this","thistype.RECYCLE_KEY()")
endmodule


endlibrary
