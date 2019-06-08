//! textmacro GenerateStructLHS takes TYPE

struct LinkedHashSet_$TYPE$ extends array
    public method begin takes nothing returns Iterator
        return LinkedHashSet(this).begin()
    endmethod
    
    public static method end takes nothing returns Iterator
        return LinkedHashSet(this).end()
    endmethod
    
    public method rBegin takes nothing returns Iterator
        return LinkedHashSet(this).rBegin()
    endmethod
    
    public static method rEnd takes nothing returns Iterator
        return LinkedHashSet(this).rEnd()
    endmethod
    
    public method next takes Iterator i returns $TYPE$
        return LinkedHashSet(this).next(i)
    endmethod
    
    public method prev takes Iterator i returns $TYPE$
        return LinkedHashSet(this).prev(i)
    endmethod
    
    public method delete takes $TYPE$ i returns nothing      
        call LinkedHashSet(this).delete(i)
    endmethod
    
    static method getEnumSet takes nothing returns thistype
        return LinkedHashSet(this).getEnumSet()
    endmethod
    
    static method getEnumElement takes nothing returns $TYPE$
        return LinkedHashSet(this).getEnumElement()
    endmethod

    method addBefore takes integer oldData, integer newData  returns nothing
        call LinkedHashSet(this).addBefore(oldData, newData)
    endmethod

    method addAfter takes integer oldData, integer newData returns nothing
        call LinkedHashSet(this).addAfter(oldData, newData)
    endmethod

    method append takes integer data returns nothing
        call LinkedHashSet(this).append(data)
    endmethod

    method prepend takes integer data returns nothing
        call LinkedHashSet(this).prepend(data)
    endmethod
    
    method remove takes integer data returns nothing
        call LinkedHashSet(this).remove(data)
    endmethod
    
    method clear takes nothing returns nothing
        call LinkedHashSet(this).clear()
    endmethod

    method getFirst takes nothing returns $TYPE$
        return LinkedHashSet(this).getFirst()
    endmethod

    method getLast takes nothing returns $TYPE$
        return LinkedHashSet(this).getLast()
    endmethod
    
    method isEmpty takes nothing returns boolean
        return LinkedHashSet(this).isEmpty()
    endmethod
    
    method contains takes integer data returns boolean
        return LinkedHashSet(this).contains(data)
    endmethod
    
    method size takes nothing returns integer
        return LinkedHashSet(this).size()
    endmethod
    
    method forEach takes trigger trig returns nothing
        call LinkedHashSet(this).forEach(trig)
    endmethod
    
    method forEachCounted takes trigger trig, integer until returns nothing
        call LinkedHashSet(this).forEachCounted(trig, until)
    endmethod
    
    method forEachCode takes code func returns nothing
        call LinkedHashSet(this).forEachCode(func)
    endmethod

    method forEachCodeCounted takes code func, integer until returns nothing
        call LinkedHashSet(this).forEachCodeCounted(func, until)
    endmethod
    
    // Returns number of elements removed
    method forEachWipe takes integer start, integer finish, code func returns integer
        return LinkedHashSet(this).forEachWipe(start, finish, func)
    endmethod

    static method create takes nothing returns thistype
        return LinkedHashSet(this).create()
    endmethod
    
    method destroy takes nothing returns nothing
        call LinkedHashSet(this).destroy()
    endmethod
endstruct
//! endtextmacro

//! textmacro GenerateStructLHSLibrary takes TYPE, LIBRARY
library_once GLHS$TYPE$ requires $LIBRARY$

struct LinkedHashSet_$TYPE$ extends array
    public method begin takes nothing returns Iterator
        return LinkedHashSet(this).begin()
    endmethod
    
    public static method end takes nothing returns Iterator
        return LinkedHashSet(this).end()
    endmethod
    
    public method rBegin takes nothing returns Iterator
        return LinkedHashSet(this).rBegin()
    endmethod
    
    public static method rEnd takes nothing returns Iterator
        return LinkedHashSet(this).rEnd()
    endmethod
    
    public method next takes Iterator i returns $TYPE$
        return LinkedHashSet(this).next(i)
    endmethod
    
    public method prev takes Iterator i returns $TYPE$
        return LinkedHashSet(this).prev(i)
    endmethod
    
    public method delete takes $TYPE$ i returns nothing      
        call LinkedHashSet(this).delete(i)
    endmethod
    
    static method getEnumSet takes nothing returns thistype
        return LinkedHashSet(this).getEnumSet()
    endmethod
    
    static method getEnumElement takes nothing returns $TYPE$
        return LinkedHashSet(this).getEnumElement()
    endmethod

    method addBefore takes integer oldData, integer newData  returns nothing
        call LinkedHashSet(this).addBefore(oldData, newData)
    endmethod

    method addAfter takes integer oldData, integer newData returns nothing
        call LinkedHashSet(this).addAfter(oldData, newData)
    endmethod

    method append takes integer data returns nothing
        call LinkedHashSet(this).append(data)
    endmethod

    method prepend takes integer data returns nothing
        call LinkedHashSet(this).prepend(data)
    endmethod
    
    method remove takes integer data returns nothing
        call LinkedHashSet(this).remove(data)
    endmethod
    
    method clear takes nothing returns nothing
        call LinkedHashSet(this).clear()
    endmethod

    method getFirst takes nothing returns $TYPE$
        return LinkedHashSet(this).getFirst()
    endmethod

    method getLast takes nothing returns $TYPE$
        return LinkedHashSet(this).getLast()
    endmethod
    
    method isEmpty takes nothing returns boolean
        return LinkedHashSet(this).isEmpty()
    endmethod
    
    method contains takes integer data returns boolean
        return LinkedHashSet(this).contains(data)
    endmethod
    
    method size takes nothing returns integer
        return LinkedHashSet(this).size()
    endmethod
    
    method forEach takes trigger trig returns nothing
        call LinkedHashSet(this).forEach(trig)
    endmethod
    
    method forEachCounted takes trigger trig, integer until returns nothing
        call LinkedHashSet(this).forEachCounted(trig, until)
    endmethod
    
    method forEachCode takes code func returns nothing
        call LinkedHashSet(this).forEachCode(func)
    endmethod

    method forEachCodeCounted takes code func, integer until returns nothing
        call LinkedHashSet(this).forEachCodeCounted(func, until)
    endmethod
    
    // Returns number of elements removed
    method forEachWipe takes integer start, integer finish, code func returns integer
        return LinkedHashSet(this).forEachWipe(start, finish, func)
    endmethod

    static method create takes nothing returns thistype
        return LinkedHashSet(this).create()
    endmethod
    
    method destroy takes nothing returns nothing
        call LinkedHashSet(this).destroy()
    endmethod
endstruct

endlibrary
//! endtextmacro