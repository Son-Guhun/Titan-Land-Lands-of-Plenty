//! runtextmacro GAL_Generate_List("true","ability","AbilityHandle","Handle","null")
////////////////////////////////////////////////////////////////////////////////////////////////////
//Guhun's Array Lists v.1.0.0
library GAL requires Lists
////////////////////////////////////////////////////////////////////////////////////////////////////
// System API
/////////////////////////////////////////
//! novjass
struct ArrayList
    method size() // returns the number of elements in the list.
    method append($type$ value) // adds the specified value at the end of the list.
    method delete(integer index) // deletes the value at the specified index from the list.
    method clear() // removes all elements from the list.
    operator [] // returns the value at the specified index.
    operator []= // sets the values of the specified index to the given value.
    
    static method getEnumList() // returns the current list in a ForEach loop.
    static method getEnumIndex() // returns the current index in a ForEach loop.
    static method getEnumValue() // retunrs the current value in a ForEach loop.
    method forEach(trigger t) // iterates over the list, executing the specified trigger.
    method forEachCounted(trigger t, integer n) // stops at 'n' executions. Negative 'n' is infinite.
    method forEachCode(code c) // executes a code variable instead of a trigger
    method forEachCodeCounted(code c)

// You can create lists of different types. The syntax of each list type is as follows:
struct ArrayListunit   // for a list of units
struct ArrayListgroup  // for a list of groups

//You can create a new list of using the following macro:
//! runtextmacro GRAL_Generate_List("true","unit","UnitHandle","Handle","null")
// 1st parameter: Always set to 'true'
// 2nd parameter: type name
// 3rd parameter: last part of the 'Load' hashtable function for the type (LoadUnitHandle, LoadReal, etc.)
// 4th parameter: last part of the 'Remove' hashtable function for the type (RemoveSavedHandle, RemoveSavedReal, etc.)
// 5th parameter: 'null' value for the type (null, 0, '', false)

//! endnovjass
////////////////////////////////////////////////////////////////////////////////////////////////////
// Configurables
/////////////////////////////////////////
globals
    public constant boolean ENABLE_GUI = false
endglobals
////////////////////////////////////////////////////////////////////////////////////////////////////
// System Source (DO NOT TOUCH ANYTHING BELOW THIS LINE)
/////////////////////////////////////////

//==============
// Utilities (Non-API functions)

// The index of the child hashtable where the size of the list is stored.
public constant function INDEX_SIZE takes nothing returns integer
    return -1
endfunction

public function SetSize takes integer listKey, integer newSize returns nothing
    call SaveInteger(Lists_GetHashtable(), listKey, INDEX_SIZE(), newSize)
endfunction

public function IsValidList takes integer listKey returns boolean
    return HaveSavedInteger(Lists_GetHashtable(), listKey, INDEX_SIZE())
endfunction

//==============
// Structs

//! textmacro GAL_Generate_List takes declareScope, type, Func, Base, NULL
library_once GAL$type$ requires GAL

    private module Methods

            method operator [] takes integer index returns $type$
                return Load$Func$(Lists_GetHashtable(), this, index)
            endmethod
            
            method operator []= takes integer index, $type$ value returns nothing
                call Save$Func$(Lists_GetHashtable(), this, index, value)
            endmethod

            //Gets the size of a specified list
            //Available since 1.0.0, replaced GetListSize
            method size takes nothing returns integer
                return LoadInteger(Lists_GetHashtable(), this, GAL_INDEX_SIZE())
            endmethod
            
            method append takes $type$ value returns integer
                local integer size = this.size()
                set this[size] = value
                call GAL_SetSize(this, size+1)
                return size
            endmethod
            
            method delete takes integer index returns nothing
                local integer size = this.size()
                set index = index + 1
                loop
                exitwhen index >= size
                    set this[index-1] = this[index]
                    set index = index + 1
                endloop
                call GAL_SetSize(this, size-1)
                call RemoveSaved$Base$(Lists_GetHashtable(), this, size-1)
            endmethod
            
            method clear takes nothing returns nothing
                call FlushChildHashtable(Lists_GetHashtable(), this)
                call GAL_SetSize(this, 0)
            endmethod
            
            method randomize takes nothing returns nothing
                local integer i = .size() - 1
                local $type$ temp
                local integer j
                
                loop
                exitwhen i <= 0
                    set j = GetRandomInt(0, i)
                    
                    set temp = this[i]
                    set this[i] = this[j]
                    set this[j] = temp
                    
                    set i = i - 1
                endloop
                
            endmethod
            
            method copy takes nothing returns thistype
                local thistype result = thistype.create()
                local integer size = .size()
                local integer i = 0
                
                loop
                exitwhen i == size
                    call result.append(this[i])
                    
                    set i = i + 1
                endloop
                
                return result
            endmethod


    endmodule
    
    private module EnumGetters
        public static method getEnumList takes nothing returns thistype
            return thistype.EnumList
        endmethod
        
        public static method getEnumIndex takes nothing returns integer
            return thistype.EnumIndex
        endmethod
        
        public static method getEnumValue takes nothing returns $type$
            return thistype.EnumValue
        endmethod
    endmodule

    static if $declareScope$ then
        struct ArrayList_$type$ extends array
        
            private static thistype EnumList = 0
            private static integer EnumIndex = 0
            private static $type$ EnumValue = $NULL$
            
            implement Methods
            implement ArrayListIteratorMethods
            implement EnumGetters
            implement ArrayListForEachMethods
            
            static method create takes nothing returns thistype
                return ArrayList.create()
            endmethod
            
            method destroy takes nothing returns nothing
                call ArrayList(this).destroy()
            endmethod
        endstruct
    else
        struct ArrayList extends array
        
            // Operators must be declared here because private module operators are not supported
            static constant method RECYCLE_KEY takes nothing returns integer
                return Lists_RECYCLE_KEY
            endmethod

            private static thistype EnumList = 0
            private static integer EnumIndex = 0
            private static $type$ EnumValue = $NULL$
            
            implement Methods
            implement ArrayListIteratorMethods
            implement EnumGetters
            implement ArrayListForEachMethods
            
            static method create takes nothing returns ArrayList
                local integer this
                implement GMUI_allocate_this
                call GAL_SetSize(this, 0)
                return this
            endmethod
            
            method destroy takes nothing returns nothing
                if GAL_IsValidList(this) then
                    call FlushChildHashtable(Lists_GetHashtable(), this)
                    implement GMUI_deallocate_this
                endif   
            endmethod
        endstruct
    endif
endlibrary
//! endtextmacro

////////////////////////////////////////////////////////////////////////////////////////////////////
//End of Interateable Ordered Lists
endlibrary
//! runtextmacro GAL_Generate_List("false","integer","Integer","Integer","0")
////////////////////////////////////////////////////////////////////////////////////////////////////

static if GAL_ENABLE_GUI then
    function Trig_GAL_Main_Actions takes nothing returns nothing
        if udg_Lists_ListID <= 0 then
            set udg_Lists_ListID = ArrayList.create()
        else
            call ArrayList(udg_Lists_ListID).destroy()
        endif
    endfunction

    function Trig_GAL_Main_Conditions takes nothing returns boolean
        if udg_Lists_Index < 0 then
            set udg_Lists_Index = ArrayList(udg_Lists_ListID).append(udg_Lists_Data)
        else
            call ArrayList(udg_Lists_ListID).delete(udg_Lists_Index)
        endif
        return false
    endfunction
    //===========================================================================
    function InitTrig_GAL_Main takes nothing returns nothing
        set gg_trg_GAL_Main = CreateTrigger(  )
        call TriggerAddAction( gg_trg_GAL_Main, function Trig_GAL_Main_Actions )
        call TriggerAddCondition( gg_trg_GAL_Main, Condition(function Trig_GAL_Main_Conditions))
    endfunction
endif

