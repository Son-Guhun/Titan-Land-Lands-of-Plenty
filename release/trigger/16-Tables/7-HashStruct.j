library HashStruct requires HashtableWrapper
/*
A mostly incomplete library that functions like TableStruct. It does not provide the same handle
field functionaly as TableStruct, so it is recommended to use the HashStruct_NewPrimitiveGetterSetter
for handles, which defines methods instead of method operators. With methods, the user can expect that
a null parameter is invalid, unlike with method operators, which should always accept a null rvalue
when setting.
*/

//! textmacro HashStruct_SetHashtableWrapper takes WRAPPER
    static constant method operator hashTable takes nothing returns $WRAPPER$
        return 0  // Return type does not matter, since this is not used as a hashtable.
    endmethod
    
    static method operator hashTableHandle takes nothing returns hashtable
        return $WRAPPER$.hashtable
    endmethod
    
    static method getChildTable takes integer i returns $WRAPPER$_Child
        return i
    endmethod
//! endtextmacro




//! textmacro HashStruct_NewPrimitiveGetterSetter takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method get$NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$[$NAME$_INDEX]
    endmethod
    
    method set$NAME$ takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method clear$NAME$ takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method has$NAME$ takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro


// ==================================
// Primitive Fields

//! textmacro HashStruct_NewPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$.has($NAME$_INDEX)
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
        return thistype.getChildTable(this)[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this)[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyStructField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this)[$NAME$_INDEX]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this)[$NAME$_INDEX] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).has($NAME$_INDEX)
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
// Number Fields

//! textmacro HashStruct_NewNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] + $DEFAULT$
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$.has($NAME$_INDEX)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] + $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        implement assertNotNull
        set thistype.getChildTable(this).$TYPE$[$NAME$_INDEX] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        implement assertNotNull
        call thistype.getChildTable(this).$TYPE$.remove($NAME$_INDEX)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).$TYPE$.has($NAME$_INDEX)
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
        return thistype.getChildTable(this).boolean.has($NAME$_INDEX) != $DEFAULT$
    endmethod
    
    method operator $NAME$= takes boolean value returns nothing
        implement assertNotNull
        call HashStruct_SetBooleanField($DEFAULT$, thistype.hashTableHandle, this, $NAME$_INDEX, value)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyBooleanFieldWithDefault takes NAME, DEFAULT
    public static key $NAME$_INDEX
    public static constant boolean $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns boolean
        implement assertNotNull
        return thistype.getChildTable(this).boolean.has($NAME$_INDEX) != $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes boolean value returns nothing
        implement assertNotNull
        call HashStruct_SetBooleanField($DEFAULT$, thistype.hashTableHandle, this, $NAME$_INDEX, value)
    endmethod
//! endtextmacro




endlibrary