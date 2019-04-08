////////////////////////////////////////////////////////////////////////////////////////////////////
//Guhun's MUI Engine version 3.0.0
library GMUI
////////////////////////////////////////////////////////////////////////////////////////////////////

globals

    public constant integer GENERIC_KEY = 0
    public constant boolean ENABLE_GUI = false
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
//! endtextmacro

// Recycles the value of variable "var_name" in the specified recycle key. Does not alter "var_name".
//! textmacro GMUI_RecycleIndex takes var_name,recycle_key
    call SaveInteger(hashTable, $recycle_key$, $var_name$, LoadInteger(hashTable, $recycle_key$, 0))
    call SaveInteger(hashTable, $recycle_key$, 0, $var_name$)
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
    private constant key _recycleKey
    
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

//

// When creating a new Recycle Key, you must call this function.
public function InitializeRecycleKey takes integer newKey returns nothing
        call SaveInteger(hashTable, newKey, 0, 1)
endfunction

// ==================
// GUI Recycle Key Generation
// ==================
static if ENABLE_GUI then
    globals
        public boolexpr array Init_Funcs
        public integer Init_Funcs_Size = 0
    endglobals
endif

// Textmacro that allows GUI users to more easily create constant Recycle Keys.
//! textmacro GMUI_GUI_CreateRecycleKey takes GLOBAL
// If GUI is not enabled, $GLOBAL$ will just be zero, which is GENERIC_RECYCLE_KEY, unless user 
// specifies a value in the Variable Editor (which is unlikely).
static if GMUI_ENABLE_GUI then
    globals
        constant key $GLOBAL$_RECYCLE_KEY
    endglobals

    // After GUI initializes user-defined globals (after vJass init), we must set our desired value again.
    function Init_$GLOBAL$func takes nothing returns boolean
        set udg_$GLOBAL$ = $GLOBAL$_RECYCLE_KEY
        return false
    endfunction

    module $GLOBAL$mod_    
        private static method onInit takes nothing returns nothing
            call GMUI_InitializeRecycleKey($GLOBAL$_RECYCLE_KEY)
            set udg_$GLOBAL$ = $GLOBAL$_RECYCLE_KEY
            set GMUI_Init_Funcs[GMUI_Init_Funcs_Size] = Filter(function Init_$GLOBAL$func)
            set GMUI_Init_Funcs_Size = GMUI_Init_Funcs_Size + 1
        endmethod
    endmodule
    struct $GLOBAL$stct extends array
        implement $GLOBAL$mod_
    endstruct
endif
//! endtextmacro
// ==================

////////////////////////////////////////////////////////////////////////////////////////////////////
//End of MUI Engine
endlibrary
////////////////////////////////////////////////////////////////////////////////////////////////////

static if GMUI_ENABLE_GUI then


    function Trig_GMUI_Main_Conditions takes nothing returns boolean
        if udg_GMUI_Index == 0 then
            set udg_GMUI_Index =  GMUI_GetIndex(GMUI_GENERIC_KEY)
        else
            call GMUI_RecycleIndex(GMUI_GENERIC_KEY, udg_GMUI_Index)
        endif
        return false
    endfunction
        
    function Trig_GMUI_Main_Actions takes nothing returns nothing
        if not HaveSavedInteger(GMUI_hashTable, udg_GMUI_RecycleKey, 0) then
            call GMUI_InitializeRecycleKey(udg_GMUI_RecycleKey)
        endif
    endfunction


    //===========================================================================
    function InitTrig_GMUI_Main takes nothing returns nothing
        local integer i = 0
        set gg_trg_GMUI_Main = CreateTrigger()
        
        loop
        exitwhen i >= GMUI_Init_Funcs_Size
            call ForceEnumPlayers(bj_FORCE_PLAYER[0], GMUI_Init_Funcs[i])
            call DestroyBoolExpr(GMUI_Init_Funcs[i])
            set GMUI_Init_Funcs[i] = null
            set i = i+1
        endloop
        
        call TriggerAddCondition(gg_trg_GMUI_Main, Condition(function Trig_GMUI_Main_Conditions))
    endfunction
endif

