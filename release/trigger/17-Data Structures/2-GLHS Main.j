////////////////////////////////////////////////////////////////////////////////////////////////////
//GLHS : Guhun's Linked Hash Sets v1.0.0

// An implementation of an ordered set with a linked list backend. AKA. LinkedHashSet.
library GLHS requires Lists
////////////////////////////////////////////////////////////////////////////////////////////////////
// System API
/////////////////////////////////////////
//! novjass
struct LinkedHashSet extends array
    method append(integer value) // adds the specified value at the end of the set.
    method prepend(integer value) // adds the specified value at the beginning of the set.
    method addBefore(integer old, integer new) // adds 'new' before 'old' in the set.
    method addAfter(integer old, integer new) // adds 'new' after 'old' in the set.
    method remove()
    
    method getFirst() //returns the first element in the set. 0 is returned for an empty set.
    method getLast() //returns the last element in the set. 0 is returned for an empty set.
    method size() // returns the number of elements in the set.
    
    method contains(integer value) // returns 'true' if 'value' is in the set, false otherwise.
    method isEmpty(integer value) // returns 'true' if the set has no elements, false otherwise.
    
    
    
    method delete(integer index) // deletes the value at the specified index from the set.
    method clear() // removes all elements from the set.
    operator [] // returns the value at the specified index.
    operator []= // sets the values of the specified index to the given value.
    
    static method getEnumList() // returns the current set in a ForEach loop.
    static method getEnumIndex() // returns the current index in a ForEach loop.
    static method getEnumValue() // retunrs the current value in a ForEach loop.
    method forEach(trigger t) // iterates over the set, executing the specified trigger.
    method forEachCounted(trigger t, integer n) // stops at 'n' executions. Negative 'n' is infinite.
    method forEachCode(code c) // executes a code variable instead of a trigger
    method forEachCodeCounted(code c)
    method forEachWipe(integer start, integer end, code c) /* iterates over all elements between 
    'start' and 'finish' in the set. This does not iterate over the start and finish values. Removes
    each value iterated over from the set. */
    
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


//==============================================
// Utilities (Private functions)
//==============================================

// If a negative setKey is specified, this will actually set the previous element of the positive setKey
private function SetNext takes integer setKey, integer data, integer next returns nothing
    call SaveInteger(Lists_GetHashtable(), setKey, data, next)
endfunction

// If a negative setKey is specified, this will actually set the next element of the positive setKey
private function SetPrev takes integer setKey, integer data, integer prev returns nothing
    call SaveInteger(Lists_GetHashtable(), -setKey, data, prev)
endfunction

// These functions clear the link data of an element (used to remove stuff from the list)
private function ClearNext takes integer setKey, integer data returns nothing
    call RemoveSavedInteger(Lists_GetHashtable(), setKey, data)
endfunction
    
private function ClearPrev takes integer setKey, integer data returns nothing
    call RemoveSavedInteger(Lists_GetHashtable(), -setKey, data)
endfunction

//Returns the next element after the specified "data" in the set
//To get the first element, pass "0" as the parameter "data"
private function GetNext takes integer setKey, integer data returns integer
    return LoadInteger(Lists_GetHashtable(), setKey, data)
endfunction

//Returns the element that preceeds the specified "data" in the set
//To get the last element, pass "0" as the parameter "data"
private function GetPrev takes integer setKey, integer data returns integer
    return LoadInteger(Lists_GetHashtable(), -setKey, data)
endfunction

//Adds an element to a set, in the position preceeding the element passed as the second parameter
//If data is already present in set, behaviour is undefined
private function AddBefore takes integer setKey, integer next, integer data returns nothing
    local integer prev = GetPrev(setKey, next)
    
    call SetNext(setKey, prev, data)
    call SetPrev(setKey, next, data)
    
    call SetNext(setKey, data, next)
    call SetPrev(setKey, data, prev)  
endfunction

//==============================================
// System API
//==============================================

private module Iter
    public method begin takes nothing returns Iterator
        return GetNext(this, 0)
    endmethod
    
    public static method end takes nothing returns Iterator
        return 0
    endmethod
    
    public method rBegin takes nothing returns Iterator
        return GetPrev(this, 0)
    endmethod
    
    public static method rEnd takes nothing returns Iterator
        return 0
    endmethod
    
    public method next takes Iterator i returns Iterator
        return GetNext(this, i)
    endmethod
    
    public method prev takes Iterator i returns Iterator
        return GetPrev(this, i)
    endmethod
    
    private method setNext takes Iterator i, Iterator next returns nothing
        call SetNext(this, i, next)
    endmethod
    
    private method setPrev takes Iterator i, Iterator prev returns nothing
        call SetPrev(this, i, prev)
    endmethod
    
    public method delete takes Iterator i returns nothing      
        local Iterator next = GetNext(this, prev)
        local Iterator prev = GetPrev(this, next)
    
        call SetPrev(this, next, prev)
        call SetNext(this, prev, next)
            
        call ClearNext(this, i)
        call ClearPrev(this, i)
    endmethod
endmodule

struct LinkedHashSet extends array

    public method begin takes nothing returns Iterator
        return GetNext(this, 0)
    endmethod
    
    public static method end takes nothing returns Iterator
        return 0
    endmethod
    
    public method rBegin takes nothing returns Iterator
        return GetPrev(this, 0)
    endmethod
    
    public static method rEnd takes nothing returns Iterator
        return 0
    endmethod
    
    public method next takes Iterator i returns Iterator
        return GetNext(this, i)
    endmethod
    
    public method prev takes Iterator i returns Iterator
        return GetPrev(this, i)
    endmethod
    
    private method setNext takes Iterator i, Iterator next returns nothing
        call SetNext(this, i, next)
    endmethod
    
    private method setPrev takes Iterator i, Iterator prev returns nothing
        call SetPrev(this, i, prev)
    endmethod
    
    public method delete takes Iterator i returns nothing      
        local Iterator next = GetNext(this, i)
        local Iterator prev = GetPrev(this, i)
    
        call SetPrev(this, next, prev)
        call SetNext(this, prev, next)
            
        call ClearNext(this, i)
        call ClearPrev(this, i)
    endmethod

    private static constant method RECYCLE_KEY takes nothing returns integer
        return Lists_RECYCLE_KEY
    endmethod
    
    static if not ENABLE_GUI then
        private static integer enumElement = 0
        private static LinkedHashSet enumSet = 0
    else
        private static method operator enumElement takes nothing returns integer
            return udg_Lists_Data
        endmethod
        private static method operator enumElement= takes integer element returns nothing
            set udg_Lists_Data = element
        endmethod
        private static method operator enumSet takes nothing returns LinkedHashSet
            return udg_Lists_ListID
        endmethod
        private static method operator enumSet= takes integer element returns nothing
            set udg_Lists_ListID = element
        endmethod
    endif
    
    static method getEnumSet takes nothing returns LinkedHashSet
        return thistype.enumSet
    endmethod
    
    static method getEnumElement takes nothing returns integer
        return thistype.enumElement
    endmethod
    
    /* DOC: addBefore(integer, integer)
    Adds an element before the element 'oldData' in the set. If the set does not contain 'oldData',
    behaviour is undefined.
    */
    method addBefore takes integer oldData, integer newData  returns nothing
        call AddBefore(this, oldData, newData) 
    endmethod
    
    /* DOC: addAfter(integer, integer)
    Adds an element after the element 'oldData' in the set. If the set does not contain 'oldData',
    behaviour is undefined.
    */
    method addAfter takes integer oldData, integer newData returns nothing
        call AddBefore(-this, oldData, newData)
    endmethod

    /* DOC: append(integer)
    Adds an element to the end of the set.
    */
    method append takes integer data returns nothing
        call this.addBefore(0, data)
    endmethod
    
    /* DOC: prepend(integer)
    Adds an element to the start of the set.
    */
    method prepend takes integer data returns nothing
        call this.addAfter(0, data)
    endmethod
    
    /* DOC: remove(integer)
    Removes an element from the set. If the set does not contain the element, behaviour is undefined.
    */
    method remove takes integer data returns nothing
        call this.delete(data)
    endmethod
    
    /* DOC: clear()
    Removes all elements from the set.
    */
    method clear takes nothing returns nothing
        call FlushChildHashtable(Lists_GetHashtable(), this)
        call FlushChildHashtable(Lists_GetHashtable(), -this)
    endmethod
    
    /* DOC: getFirst()
    Returns the first element in the set.
    */
    method getFirst takes nothing returns integer
        return this.begin()
    endmethod
    
    /* DOC: getLast()
    Returns the last element in the set.
    */
    method getLast takes nothing returns integer
        return this.rBegin()
    endmethod
    
    /* DOC: isEmpty()
    Returns whether a set is empty. A set is empty when its first element is zero.
    */
    method isEmpty takes nothing returns boolean
        return this.begin() == this.end()
    endmethod
    
    /* DOC: contains(integer)
    Returns whether a set contains a certain element.
    */
    method contains takes integer data returns boolean
        return HaveSavedInteger(Lists_GetHashtable(), this, data)
    endmethod
    
    /* DOC: getFirst()
    Returns the size of the set. This is an O(n) operation.
    */
    method size takes nothing returns integer
        local integer data = this.begin()
        local integer count = 0
        
        loop
        exitwhen data == this.end()
            set count = count + 1
            set data = this.next(data)
        endloop
        
        return count
    endmethod
    
    //This function loops through a Set and executes a trigger for each element, setting the udg_List variables to their relevant equivalents each time
    method forEach takes trigger trig returns nothing
        local Iterator data = this.begin()
        
        loop
        exitwhen data == this.end()
            set enumElement= data
            set enumSet = this
            
            set data = this.next(data)
            
            if IsTriggerEnabled(trig) and TriggerEvaluate(trig) then
                call TriggerExecute(trig)
            endif
        endloop
    endmethod
    
    //If 'until' parameter is a non-negative number, then the loop will break after iterating over that many elements
    method forEachCounted takes trigger trig, integer until returns nothing
        local Iterator data = this.begin()
        local integer count = 0
            
        loop
        exitwhen data == this.end() or count == until
            set enumElement= data
            set enumSet = this
            
            set data = this.next(data)
            
            if IsTriggerEnabled(trig) and TriggerEvaluate(trig) then
                call TriggerExecute(trig)
            endif
            
            set count = count + 1
        endloop
    endmethod
    
    // You may specify a code that will run in a ForPlayer loop instead of a trigger
    method forEachCode takes code func returns nothing
        local integer data = this.begin()
        
        loop
        exitwhen data == this.end()
            set enumElement= data
            set enumSet = this
            
            set data = this.next(data)
            
            call ForForce(bj_FORCE_PLAYER[0], func)
        endloop
    endmethod
    /*
    method forEachCode takes code func returns nothing
        local integer data = this.begin()
        
        loop
        exitwhen data == this.end()
            set enumElement= data
            set enumSet = this
            
            set data = this.next(data)
            
            call ForceEnumPlayers()(bj_FORCE_PLAYER[0], func)
        endloop
    endmethod
    */
    
    method forEachCodeCounted takes code func, integer until returns nothing
        local Iterator data = this.begin()
        local integer count = 0
            
        loop
        exitwhen data == this.end() or count == until
            set enumElement= data
            set enumSet = this
            
            set data = this.next(data)
            
            call ForForce(bj_FORCE_PLAYER[0], func)
            
            set count = count + 1
        endloop
    endmethod
    
    method forEachWipe takes integer start, integer finish, code func returns integer
        local integer data = GetNext(this, start)
        local integer nextData
        local integer countRemoved = 0
            
        loop
        exitwhen data == finish or data == 0
        
            set nextData = GetNext(this, data)

            call ClearNext(this, data)
            call ClearPrev(-this, data)
            
            set enumElement = data
            set enumSet = this
            call ForForce(bj_FORCE_PLAYER[0], func)

            set data = nextData
            set countRemoved = countRemoved + 1
        endloop
        
        call SetPrev(this, data, start)
        call SetNext(this, start, data)

        return countRemoved
    endmethod

    /* DOC: static create()
    Creates a new set and returns it.
    */
    static method create takes nothing returns LinkedHashSet
        return GMUI_GetIndex(RECYCLE_KEY())
    endmethod
    
    /* DOC: destroy()
    Destroys a set and clears all of its data.
    */
    method destroy takes nothing returns nothing
        call FlushChildHashtable(Lists_GetHashtable(), this)
        call FlushChildHashtable(Lists_GetHashtable(), -this)
        implement GMUI_deallocate_this
    endmethod
    
endstruct
////////////////////////////////////////////////////////////////////////////////////////////////////
endlibrary
//End of Ordered Sets
////////////////////////////////////////////////////////////////////////////////////////////////////

static if GLHS_ENABLE_GUI then
    function Trig_GLL_Main_Actions takes nothing returns nothing
        if enumSet == 0 then
            set enumSet = LinkedHashSet.create()
        else
            call LinkedHashSet(enumSet).destroy()
        endif
    endfunction

    function Trig_GLL_Main_Conditions takes nothing returns boolean
        if HaveSavedInteger(Lists_GetHashtable(), enumSet, enumElement)  then //Faster than GLL_ListHasData function
            call LinkedHashSet(enumSet).remove(enumElement)
        else
            call LinkedHashSet(enumSet).addBefore(udg_Lists_Index, enumElement)
        endif
        return false
    endfunction
    //===========================================================================
    function InitTrig_GLHS_Main takes nothing returns nothing
        set gg_trg_GLHS_Main = CreateTrigger(  )
        call TriggerAddAction( gg_trg_GLHS_Main, function Trig_GLL_Main_Actions )
        call TriggerAddCondition( gg_trg_GLHS_Main, Condition(function Trig_GLL_Main_Conditions))
    endfunction
endif

