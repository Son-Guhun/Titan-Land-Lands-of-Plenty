library HashStruct requires optional Table, optional HashtableWrapper
/*
This library functions like TableStruct. However, it can use any hashtable wrapped with HashtableWrapper.

This allows you to simply use this.tab.flush() when destroying a struct, instead of having to clear
each field individually, like you would have to do with TableStruct.

//! textmacro HashStruct_SetHashtableWrapper takes WRAPPER
    static constant hashTable -> returns the wrapper
    
    $WRAPPER$child tab -> this struct, but typecaste to a table of the wrapped hashtable

// Using the ExtendsTable module requires you to allocate your structs using Table.create()
module ExtendsTable
    Table tab -> this struct, but typecasted to a table
*/
//! novjass
struct Point extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("pointHashtable")

    //! HashStruct_NewReadonlyPrimitiveFieldIndexed("x", "real", "0")
    //! HashStruct_NewReadonlyPrimitiveFieldIndexed("y", "real", "1")
    
    static method create takes real x, real y returns thistype
        local integer this = thistype.allocate()  // allocator is implemented from some other library
        
        set .x = x  // same as .tab[0] = x, since we used index 0 for the x field
        set .y = y  // same as .tab[1] = x, since we used index 0 for the x field
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call .tab.flush()
    endmethod
//! endnovjass




//! textmacro HashStruct_SetHashtableWrapper takes WRAPPER
    static constant method operator hashTable takes nothing returns $WRAPPER$
        return 0  // Return value does not matter, since this is not used as a hashtable.
    endmethod
    
    method operator tab takes nothing returns $WRAPPER$_Child
        return this
    endmethod
//! endtextmacro

// Boolean fields with default values don't work with this table because the Table hashtable is private.
module ExtendsTable

    method operator tab takes nothing returns Table
        return this
    endmethod
    
endmodule

//! textmacro HashStruct_NewPrimitiveGetterSetter takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method get$NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method set$NAME$ takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method clear$NAME$ takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method has$NAME$ takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro


// ==================================
// Primitive Fields

//! textmacro HashStruct_NewPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewPrimitiveFieldIndexed takes NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$INDEX$] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($INDEX$)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewReadonlyPrimitiveFieldIndexed takes NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$INDEX$]
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$INDEX$] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($INDEX$)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewPrimitiveFieldEx takes HASHTABLE, NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return $HASHTABLE$[this].$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set $HASHTABLE$[this].$TYPE$[$INDEX$] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call $HASHTABLE$[this].$TYPE$.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return $HASHTABLE$[this].$TYPE$.has($INDEX$)
    endmethod
//! endtextmacro

// ==================================
// Struct Fields

//! textmacro HashStruct_NewStructField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$ 
        implement assertNotNull
        return this.tab[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyStructField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyStructFieldIndexed takes NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab[$INDEX$] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($INDEX$)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewStructFieldEx takes HASHTABLE, NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return $HASHTABLE$[this][$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set $HASHTABLE$[this][$INDEX$] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call $HASHTABLE$[this].remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return $HASHTABLE$[this].has($INDEX$)
    endmethod
//! endtextmacro

// ==================================
// Handle Fields

//! textmacro HashStruct_NewHandleField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$ 
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.handle.setValue($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.handle.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyHandleField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.handle.setValue($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.handle.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewHandleFieldIndexed takes NAME, TYPE, INDEX    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.handle.setValue($INDEX$, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.handle.has($INDEX$)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyHandleFieldIndexed takes NAME, TYPE, INDEX    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$INDEX$]
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.handle.setValue($INDEX$, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.handle.has($INDEX$)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewHandleFieldEx takes HASHTABLE, NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return $HASHTABLE$[this].$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.handle.setValue($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call $HASHTABLE$[this].remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return $HASHTABLE$[this].handle.has($INDEX$)
    endmethod
//! endtextmacro


// ==================================
// Agent Fields

//! textmacro HashStruct_NewAgentField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$ 
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.agent.setVal($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyAgentField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.agent.setVal($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyAgentFieldIndexed takes NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.agent.setVal($INDEX$, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.has($INDEX$)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewAgentFieldEx takes HASHTABLE, NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return $HASHTABLE$[this].$TYPE$[$INDEX$]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        call this.tab.agent.setVal($NAME$_INDEX, new_$NAME$)
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call $HASHTABLE$[this].remove($INDEX$)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return $HASHTABLE$[this].has($INDEX$)
    endmethod
//! endtextmacro


// ==================================
// Number Fields

//! textmacro HashStruct_NewNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX] + $DEFAULT$
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$NAME$_INDEX] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return this.tab.$TYPE$[$NAME$_INDEX] + $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set this.tab.$TYPE$[$NAME$_INDEX] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call this.tab.$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return this.tab.$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

// ==================================
// Boolean Fields

public function SetBooleanField takes boolean default, hashtable whichHashtable, integer parentKey, integer childKey, boolean value returns nothing
    
    if value == default then
        call RemoveSavedBoolean(whichHashtable, parentKey, childKey)
    else
        call SaveBoolean(whichHashtable, parentKey, childKey, true)
    endif

endfunction

//! textmacro HashStruct_NewBooleanFieldWithDefault takes NAME, DEFAULT
    public static key $NAME$_INDEX
    public static constant boolean $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns boolean
        implement assertNotNull
        return this.tab.boolean.has($NAME$_INDEX) != $DEFAULT$
    endmethod
    
    method operator $NAME$= takes boolean value returns nothing
        implement assertNotNull
        call HashStruct_SetBooleanField($DEFAULT$, thistype.hashTable.hashtable, this, $NAME$_INDEX, value)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyBooleanFieldWithDefault takes NAME, DEFAULT
    public static key $NAME$_INDEX
    public static constant boolean $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns boolean
        implement assertNotNull
        return this.tab.boolean.has($NAME$_INDEX) != $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes boolean value returns nothing
        implement assertNotNull
        call HashStruct_SetBooleanField($DEFAULT$, thistype.hashTable.hashtable, this, $NAME$_INDEX, value)
    endmethod
//! endtextmacro




endlibrary