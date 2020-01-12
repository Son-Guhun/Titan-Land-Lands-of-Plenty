library TableStruct requires Table, optional ConstTable
// Defines Structs that use Table (or ConstTable) as a backend, instead of arrays.
// You should use your own allocator (for non-static structs).

static if LIBRARY_ConstTable then
    private module Const
        static method type takes integer i returns ConstTable
            return i
        endmethod
    endmodule
else
    private module Dynmc
        static method type takes integer i returns Table
            return i
        endmethod
    endmodule
endif

struct TableStruct extends array
    static if LIBRARY_ConstTable then
        implement Const
    else
        implement Dynmc
    endif
    
    static method setHandle takes integer parent, integer child, handle h returns nothing
        if h != null then
            set .type(parent).fogstate[child] = ConvertFogState(GetHandleId(h))
        else
            call .type(parent).handle.remove(child)
        endif
    endmethod
    
    static method setAgent takes integer parent, integer child, agent a returns nothing
        if a != null then
            set .type(parent).agent[child] = a
        else
            call .type(parent).handle.remove(child)
        endif
    endmethod
endstruct

//! textmacro TableStruct_NewConstTableField takes access, NAME
    private static key $NAME$_impl
    static if LIBRARY_ConstTable then
        $access$ static constant method operator $NAME$ takes nothing returns ConstTable
            return $NAME$_impl
        endmethod
    else
        $access$ static constant method operator $NAME$ takes nothing returns Table
            return $NAME$_impl
        endmethod
    endif
//! endtextmacro

//! textmacro TableStruct_NewReadonlyStaticStructField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key)[thistype.$NAME$_impl]
    endmethod
    
    private static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.static_members_key)[thistype.$NAME$_impl] = new_$NAME$
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyStaticPrimitiveField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl]
    endmethod
    
    private static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl] = new_$NAME$
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).$TYPE$.remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).$TYPE$.has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyStaticHandleField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl]
    endmethod
    
    private static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        call TableStruct.setHandle(thistype.static_members_key, thistype.$NAME$_impl, new_$NAME$)
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).$TYPE$.remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).$TYPE$.has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewStaticStructField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key)[thistype.$NAME$_impl]
    endmethod
    
    static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.static_members_key)[thistype.$NAME$_impl] = new_$NAME$
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewStaticPrimitiveField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl]
    endmethod
    
    static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl] = new_$NAME$
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).$TYPE$.remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).$TYPE$.has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewStaticHandleField takes NAME, TYPE
    private static key $NAME$_impl
    static method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.static_members_key).$TYPE$[thistype.$NAME$_impl]
    endmethod
    
    static method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        call TableStruct.setHandle(thistype.static_members_key, thistype.$NAME$_impl, new_$NAME$)
    endmethod
    
    private static method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).$TYPE$.remove(thistype.$NAME$_impl)
    endmethod
    
    private static method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.static_members_key).$TYPE$.has(thistype.$NAME$_impl)
    endmethod
//! endtextmacro


//! textmacro TableStruct_NewStructField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl)[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.$NAME$_impl)[this] = new_$NAME$
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).has(this)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewPrimitiveField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.$NAME$_impl).$TYPE$[this] = new_$NAME$
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$.has(this)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewHandleField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$[this]
    endmethod
    
    method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        call TableStruct.setHandle(thistype.$NAME$_impl, this, new_$NAME$)
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$.has(this)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyStructField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl)[this]
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.$NAME$_impl)[this] = new_$NAME$
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).has(this)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyPrimitiveField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$[this]
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        set TableStruct.type(thistype.$NAME$_impl).$TYPE$[this] = new_$NAME$
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$.has(this)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyHandleField takes NAME, TYPE
    private static key $NAME$_impl
    method operator $NAME$ takes nothing returns $TYPE$
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$[this]
    endmethod
    
    private method operator $NAME$= takes $TYPE$ new_$NAME$ returns nothing
        call TableStruct.setHandle(thistype.$NAME$_impl, this, new_$NAME$)
    endmethod
    
    private method $NAME$Clear takes nothing returns nothing
        call TableStruct.type(thistype.$NAME$_impl).$TYPE$.remove(this)
    endmethod
    
    private method $NAME$Exists takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).$TYPE$.has(this)
    endmethod
//! endtextmacro

public function SetBooleanField takes boolean default, integer parentKey, integer childKey, boolean value returns nothing
    
    if value == default then
        call TableStruct.type(parentKey).boolean.remove(childKey)
    else
        set TableStruct.type(parentKey).boolean[childKey] = true
    endif

endfunction

// Boolean Fields
//! textmacro TableStruct_NewBooleanFieldWithDefault takes NAME, DEFAULT
    public static key $NAME$_impl
    public static constant boolean $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).boolean.has(this) != $DEFAULT$
    endmethod
    
    method operator $NAME$= takes boolean value returns nothing
        call TableStruct_SetBooleanField($DEFAULT$, $NAME$_impl, this, value)
    endmethod
//! endtextmacro

//! textmacro TableStruct_NewReadonlyBooleanFieldWithDefault takes NAME, DEFAULT
    public static key $NAME$_impl
    public static constant boolean $NAME$_DEFAULT = $DEFAULT$
    
    method operator $NAME$ takes nothing returns boolean
        return TableStruct.type(thistype.$NAME$_impl).boolean.has(this) != $DEFAULT$
    endmethod
    
    private method operator $NAME$= takes boolean value returns nothing
        call TableStruct_SetBooleanField($DEFAULT$, $NAME$_impl, this, value)
    endmethod
//! endtextmacro

endlibrary