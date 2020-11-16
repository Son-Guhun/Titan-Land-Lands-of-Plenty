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

//You can create new list structs for different typs using the following macro:
//! runtextmacro GAL_Generate_List("true","unit","UnitHandle","Handle","null")
// 1st parameter: Always set to 'true'
// 2nd parameter: type name
// 3rd parameter: last part of the 'Load' hashtable function for the type (LoadUnitHandle, LoadReal, etc.)
// 4th parameter: last part of the 'Remove' hashtable function for the type (RemoveSavedHandle, RemoveSavedReal, etc.)
// 5th parameter: 'null' value for the type (null, 0, '', false)

// The syntax of each list type is as follows:
struct ArrayList_unit   // for a list of units
struct ArrayList_group  // for a list of groups

// You have to require these libraries to use those structs.
library GALunit
library GALgroup

//! endnovjass
////////////////////////////////////////////////////////////////////////////////////////////////////
// Configurables
/////////////////////////////////////////


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

public function ClearList takes integer listKey returns nothing
    call FlushChildHashtable(Lists_GetHashtable(), listKey)
    call GAL_SetSize(listKey, 0)
endfunction

// TODO
private struct Allocator extends array
    // Operators must be declared here because private module operators are not supported
    static constant method RECYCLE_KEY takes nothing returns integer
        return Lists_RECYCLE_KEY
    endmethod

    static method create takes nothing returns thistype
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


public function CreateList takes nothing returns integer
    return Allocator.create()
endfunction

public function DestroyList takes integer this returns nothing
    call Allocator(this).destroy()
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
            method operator size takes nothing returns integer
                return LoadInteger(Lists_GetHashtable(), this, GAL_INDEX_SIZE())
            endmethod
            
            method append takes $type$ value returns integer
                local integer size = this.size
                set this[size] = value
                call GAL_SetSize(this, size+1)
                return size
            endmethod
            
            method delete takes integer index returns nothing
                local integer size = this.size
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
                call GAL_ClearList(this)
            endmethod
            
            method randomize takes nothing returns nothing
                local integer i = .size - 1
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
                local integer size = .size
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
            
            static method create takes nothing returns ArrayList_$type$
                return GAL_CreateList()
            endmethod
            
            method destroy takes nothing returns nothing
                call GAL_DestroyList(this)
            endmethod
            
            implement Methods
            implement ArrayListIteratorMethods
            implement EnumGetters
            implement ArrayListForEachMethods
        endstruct
    else
        struct ArrayList extends array
        
            private static thistype EnumList = 0
            private static integer EnumIndex = 0
            private static $type$ EnumValue = $NULL$
            
            static method create takes nothing returns ArrayList
                return GAL_CreateList()
            endmethod
            
            method destroy takes nothing returns nothing
                call GAL_DestroyList(this)
            endmethod
            
            implement Methods
            implement ArrayListIteratorMethods
            implement EnumGetters
            implement ArrayListForEachMethods
        endstruct
    endif
endlibrary
//! endtextmacro

////////////////////////////////////////////////////////////////////////////////////////////////////
//End of Interateable Ordered Lists
endlibrary
//! runtextmacro GAL_Generate_List("false","integer","Integer","Integer","0")
////////////////////////////////////////////////////////////////////////////////////////////////////

