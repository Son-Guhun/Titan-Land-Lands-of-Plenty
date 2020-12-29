////////////////////////////////////////////////////////////////////////////////////////////////////
//GLHS : Guhun's Linked Hash Sets v1.0.0

// An implementation of an ordered set with a linked list backend. AKA. LinkedHashSet.
library StaticLinkedSet requires Lists
////////////////////////////////////////////////////////////////////////////////////////////////////

//==============================================
// System API
//==============================================
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
// System Source (DO NOT TOUCH ANYTHING BELOW THIS LINE)
/////////////////////////////////////////

//! textmacro StaticLinkedSet_ForNode takes node
    set $node$ = $node$.next
    exitwhen $node$ == $node$.end()
//! endtextmacro

module StaticLinkedSetNode

    thistype next
    thistype prev
    
    
    static method operator head takes nothing returns thistype
        return 0
    endmethod

    public static method begin takes nothing returns thistype
        return head.next
    endmethod
    
    public static method end takes nothing returns thistype
        return 0
    endmethod
    
    public static method rBegin takes nothing returns thistype
        return head.prev
    endmethod
    
    public static method rEnd takes nothing returns thistype
        return 0
    endmethod
    
    public method delete takes nothing returns nothing      
        local thistype next = this.next
        local thistype prev = this.prev
    
        set next.prev = prev
        set prev.next = next
    endmethod
    
    /* DOC: addBefore(integer, integer)
    Adds an element before the element 'oldData' in the set. If the set does not contain 'oldData',
    behaviour is undefined.
    */
    method addBefore takes thistype next returns nothing
        local thistype prev = next.prev
        
        set prev.next = this
        set next.prev = this
        
        set this.next = next
        set this.prev = prev  
    endmethod
    
    /* DOC: addAfter(integer, integer)
    Adds an element after the element 'oldData' in the set. If the set does not contain 'oldData',
    behaviour is undefined.
    */
    method addAfter takes thistype prev returns nothing
        local thistype next = prev.next
        
        set prev.next = this
        set next.prev = this
        
        set this.next = next
        set this.prev = prev  
    endmethod

    /* DOC: append(integer)
    Adds an element to the end of the set.
    */
    method append takes nothing returns nothing
        call this.addBefore(0)
    endmethod
    
    /* DOC: prepend(integer)
    Adds an element to the start of the set.
    */
    method prepend takes nothing returns nothing
        call this.addAfter(0)
    endmethod
    
    /* DOC: remove(integer)
    Removes an element from the set. If the set does not contain the element, behaviour is undefined.
    */
    method remove takes nothing returns nothing
        call this.delete()
    endmethod
    
    /* DOC: getFirst()
    Returns the first element in the set.
    */
    static method getFirst takes nothing returns integer
        return .begin()
    endmethod
    
    /* DOC: getLast()
    Returns the last element in the set.
    */
    static method getLast takes nothing returns integer
        return .rBegin()
    endmethod
    
    /* DOC: isEmpty()
    Returns whether a set is empty. A set is empty when its first element is zero.
    */
    static method isEmpty takes nothing returns boolean
        return .begin() == .end()
    endmethod
    
    /* DOC: contains(integer)
    Returns whether a set contains a certain element.
    */
    // method contains takes integer data returns boolean
    //     return HaveSavedInteger(Lists_GetHashtable(), this, data)
    // endmethod
    
    /* DOC: getFirst()
    Returns the size of the set. This is an O(n) operation.
    */
    static method size takes nothing returns integer
        local thistype data = .begin()
        local integer count = 0
        
        loop
        exitwhen data == .end()
            set count = count + 1
            set data = data.next
        endloop
        
        return count
    endmethod
    
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////
endlibrary
//End of Ordered Sets
////////////////////////////////////////////////////////////////////////////////////////////////////
