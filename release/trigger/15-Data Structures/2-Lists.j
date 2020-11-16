library_once Lists requires GMUI

// --------------------------------------------------------------
// TODO: INITIALIZATION OF GLOBAL GUI VARIABLES DOES NOT WORK
// --------------------------------------------------------------

globals
    public constant key RECYCLE_KEY
endglobals

globals
    private hashtable hashTable = InitHashtable()
endglobals

public function GetHashtable takes nothing returns hashtable
    return hashTable
endfunction

//==============
//System Initialization

//==============
//For Each methods

//! textmacro Lists_LoadGlobals takes LIST, ITERATOR

    set this.EnumValue  = $LIST$[$ITERATOR$]
    set this.EnumIndex  = $ITERATOR$
    set this.EnumList   = $LIST$

//! endtextmacro
module ArrayListIteratorMethods
    public static method begin takes nothing returns Iterator
        return 0
    endmethod
    
    public method end takes nothing returns Iterator
        return this.size
    endmethod
    
    public method rBegin takes nothing returns Iterator
        return this.size - 1
    endmethod
    
    public static method rEnd takes nothing returns Iterator
        return -1
    endmethod
    
    public method next takes Iterator i returns Iterator
        return i + 1
    endmethod
    
    public method prev takes Iterator i returns Iterator
        return i - 1
    endmethod
endmodule

module ArrayListForEachMethods    
    //======
    //Functions for code/trigger loops

    //Loops over a list and executes the given trigger
    //Stops after it enconters "until" number of elements
    //If a negative "until" is specified, it will only stop when there are no more elements
    //Sets the udg_Lists_Data, Instance and ListID variables to their correct values each time before running the trigger
    method forEachCounted takes trigger trig, integer until returns nothing
        local integer end = this.end()
        local integer newEnd = end
        local integer count = 0

        local Iterator i = this.begin() 
        loop
        exitwhen count == until or i == end
            
            //! runtextmacro Lists_LoadGlobals("this", "i")
            
            if IsTriggerEnabled(trig) and TriggerEvaluate(trig) then
                call TriggerExecute(trig)
            endif
            
            set newEnd = this.end()
            if newEnd == end then 
                set i = this.next(i)
            else
                set end = newEnd
            endif
            
            set count = count + 1
        endloop
    endmethod

    method forEach takes trigger trig returns nothing
        local integer end = this.end()
        local integer newEnd = end

        local Iterator i = this.begin() 
        loop
        exitwhen i == end
            
            //! runtextmacro Lists_LoadGlobals("this", "i")
            
            if IsTriggerEnabled(trig) and TriggerEvaluate(trig) then
                call TriggerExecute(trig)
            endif
            
            set newEnd = this.end()
            if newEnd == end then 
                set i = this.next(i)
            else
                set end = newEnd
            endif
        endloop
    endmethod

    //Same as GIOL_Loop, but executes the given code in a ForPlayer loop, instead of a trigger
    //Added in version 1.1.0
    method forEachCodeCounted takes code func, integer until returns nothing
        local integer end = this.end()
        local integer newEnd = end
        local integer count = 0

        local Iterator i = this.begin() 
        loop
        exitwhen count == until or i == end
            
            //! runtextmacro Lists_LoadGlobals("this", "i")
            
            call ForForce(bj_FORCE_PLAYER[0], func)
            
            set newEnd = this.end()
            if newEnd == end then 
                set i = this.next(i)
            else
                set end = newEnd
            endif
            
            set count = count + 1
        endloop
    endmethod

    method forEachCode takes code func returns nothing
        local integer end = this.end()
        local integer newEnd = end

        local Iterator i = this.begin() 
        loop
        exitwhen i == end
            
            //! runtextmacro Lists_LoadGlobals("this", "i")
            
            call ForForce(bj_FORCE_PLAYER[0], func)
            
            set newEnd = this.end()
            if newEnd == end then 
                set i = this.next(i)
            else
                set end = newEnd
            endif
            
        endloop
    endmethod
endmodule

//! textmacro Lists_GenerateForEachFunctions takes TYPE
//======
//Functions for code/trigger loops

//Loops over a list and executes the given trigger
//Stops after it enconters "until" number of elements
//If a negative "until" is specified, it will only stop when there are no more elements
//Sets the udg_Lists_Data, Instance and this variables to their correct values each time before running the trigger
public function ForEachCounted takes $TYPE$ list, trigger trig, integer until returns nothing
    call list.forEachCounted(trig, until)
endfunction

public function ForEach takes $TYPE$ list, trigger trig returns nothing
    call list.forEach(trig)
endfunction

//Same as GIUL_Loop, but executes the given code in a ForPlayer loop, instead of a trigger
//Added in version 1.1.0
public function ForEachCodeCounted takes $TYPE$ list, code func, integer until returns nothing
    call list.forEachCodeCounted(func, until)
endfunction

public function ForEachCode takes $TYPE$ list, code func returns nothing
    call list.forEachCode(func)
endfunction
//! endtextmacro


//==============

endlibrary

library_once Iterator
    struct Iterator extends array
        
        method asInteger takes nothing returns integer
            return this
        endmethod
        
    endstruct
endlibrary