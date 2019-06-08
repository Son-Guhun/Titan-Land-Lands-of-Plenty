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
    
    static method getChildTable takes integer i returns $WRAPPER$_Child
        return i
    endmethod
//! endtextmacro




//! textmacro HashStruct_NewPrimitiveGetterSetter takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method get$NAME$ takes nothing returns $TYPE$
        return thistype.getChildTable($NAME$_INDEX).$TYPE$[this]
    endmethod
    
    method set$NAME$ takes $TYPE$ new_$NAME$ returns nothing
        set thistype.getChildTable($NAME$_INDEX).$TYPE$[this] = new_$NAME$
    endmethod
    
    private method clear$NAME$ takes nothing returns nothing
        call thistype.getChildTable($NAME$_INDEX).$TYPE$.remove(this)
    endmethod
    
    private method has$NAME$ takes nothing returns boolean
        return thistype.getChildTable($NAME$_INDEX).$TYPE$.has(this)
    endmethod
//! endtextmacro


// ==================================
// Primitive Fields

//! textmacro HashStruct_NewPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        return thistype.getChildTable($NAME$_INDEX).$TYPE$[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set thistype.getChildTable($NAME$_INDEX).$TYPE$[this] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        call thistype.getChildTable($NAME$_INDEX).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        return thistype.getChildTable($NAME$_INDEX).$TYPE$.has(this)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyPrimitiveField takes NAME, TYPE
    public static key $NAME$_INDEX
    
    method operator $NAME$ takes nothing returns $TYPE$
        return thistype.getChildTable($NAME$_INDEX).$TYPE$[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set thistype.getChildTable($NAME$_INDEX).$TYPE$[this] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        call thistype.getChildTable($NAME$_INDEX).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        return thistype.getChildTable($NAME$_INDEX).$TYPE$.has(this)
    endmethod
//! endtextmacro

// Used if you want to have control over the indices, instead of using a constant key variable
//! textmacro HashStruct_NewPrimitiveFieldEx takes HASHTABLE, NAME, TYPE, INDEX
    method operator $NAME$ takes nothing returns $TYPE$
        return $HASHTABLE$[$INDEX$].$TYPE$[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set $HASHTABLE$[$INDEX$].$TYPE$[this] = new_$NAME$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        call $HASHTABLE$[$INDEX$].$TYPE$.remove(this)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        return $HASHTABLE$[$INDEX$].$TYPE$.has(this)
    endmethod
//! endtextmacro


// ==================================
// Number Fields

//! textmacro HashStruct_NewNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        return thistype.getChildTable($NAME$_INDEX).$TYPE$[this] + $DEFAULT$
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set thistype.getChildTable($NAME$_INDEX).$TYPE$[this] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        call thistype.getChildTable($NAME$_INDEX).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        return thistype.getChildTable($NAME$_INDEX).$TYPE$.has(this)
    endmethod
//! endtextmacro

//! textmacro HashStruct_NewReadonlyNumberFieldWithDefault takes NAME, TYPE, DEFAULT
    public static key $NAME$_INDEX
    public static constant $TYPE$ $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns $TYPE$
        return thistype.getChildTable($NAME$_INDEX).$TYPE$[this] + $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set thistype.getChildTable($NAME$_INDEX).$TYPE$[this] = new_$NAME$ - $DEFAULT$
    endmethod
    
    private method $NAME$_clear takes nothing returns nothing
        call thistype.getChildTable($NAME$_INDEX).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$_exists takes nothing returns boolean
        return thistype.getChildTable($NAME$_INDEX).$TYPE$.has(this)
    endmethod
//! endtextmacro
endlibrary