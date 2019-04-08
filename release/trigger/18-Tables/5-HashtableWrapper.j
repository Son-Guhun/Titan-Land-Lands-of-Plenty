library HashtableWrapper requires /*

    */ optional Table /* If found, allows n-th dimensional hashtables.
    https://www.hiveworkshop.com/threads/snippet-new-table.188084/
    
    */ optional ConstTable /* If found, DeclareHashTableWrapperModule will use ConstHashTable
    
    
    This library permits the creation of a static struct that wraps a hashtable (or a HashTable
    struct from the Table library). This struct allows the syntax: 
        set Hashtable[0][1] = 0
        set Hashtable[0].string[2] = "Victory!"
        call Hastable[0].remove(1)
        call BJDebugMsg(Hashtable[0].string[2])
                                                            
    
    Most of the credit for this library goes to Bribe, who made the Table library, from which all
    the macros in this library are derived.

    If table is used, then the ChildHashtable struct will return a Table, which allows you to create
    nth-dimensional hashtables.
*/
//! novjass
'                                                                                                  '
'                                              API                                                 '
/* This system is implemented with the usage of textmacros. No functions, structs, modules or global
variables are defined.                                                                            */

// Wraps the marked hashtable, creating a Struct named NAME.
//! textmacro DeclareParentHashtableWrapperModule takes HASHTABLE, USE_HANDLES, NAME, ACCESS
    $HASHTABLE$ => //!The hashtable to be wrapped.
    $USE_HANDLES$ => //!Must be true, false or constant boolean variable (not empty). If false, the 
                     //!syntax for handle types is disabled. This reduces the time required to parse
                     //!the vJass script.
    $NAME$ => //!The name of the struct that will be created to wrap the hashtable.
    $ACCESS$ => //! Maybe be "public", "private" or "".
    
//! endtextmacro

// Declares a struct to wrap a hashtable. Must be called after the module with NAME is declared.
// Source code below (it's a simple text macro)
//! endnovjass
//! textmacro DeclareParentHashtableWrapperStruct takes NAME, ACCESS
    $ACCESS$ struct $NAME$ extends array
        implement $NAME$_ParentHashtableWrapper
    endstruct
//! endtextmacro
//! novjass

// This textmacro is used to make the library an optional requirement. It creates a Struct that 
// wraps a HashTable Struct (declared in the Table library v4.0+). This struct's syntax is identical
// to the one created by DeclareParentHashtableWrapper
//! textmacro_once DeclareHashTableWrapperModule takes NAME
    $NAME$ => //!The name of the struct that will be created to wrap the HashTable.
//! endtextmacro

//===================================================
// Wrapper Methods
//===================================================
// These are the methods of the wrapper. $NAME$ is substituted for the name of the wrapper.

struct $NAME$_Child
    //! Implements all methods of a Table struct, except create() and destroy().
    
    //! The [] operator returns integer if Table is not present. Otherwise, it returns Table.
endstruct

struct $NAME$
    static method operator[] takes integer key returns $NAME$_Child
        //! Returns a child hashtable. Permits $NAME$[0][1] syntax.

    static method flushChild takes integer key returns nothing
        //! Flushes a child hashtable (equivalent to $NAME$[key].flush)

    static method flush takes nothing returns nothing
        //! Flushes the hashtable.

    static method operator hashtable takes nothing returns hashtable
        //! Returns the hashtable that this struct wraps.
endstruct

//===================================================
// Simple Examples
//===================================================

// Simplest Example
library SimplestExample
    globals
        private hashtable hash
    endglobals  
    //! runtextmacro DeclareParentHashtableWrapperModule("hash", "true", "GeneralHashtable", "private")
    //! runtextmacro DeclareParentHashtableWrapperStruct("GeneralHashtable","private")
endlibrary

// Declaring two Wrappers
library Example initializer onInit requires HashtableWrapper

    globals
        private hashtable hash1 = InitHashtable()
        private hashtable hash2 = InitHashtable()
    endglobals

    //! runtextmacro DeclareParentHashtableWrapperModule("hash1", "true", "Hashtable_1", "")
    //! runtextmacro DeclareParentHashtableWrapperModule("hash2", "true", "Hashtable_2", "")

    //! runtextmacro DeclareParentHashtableWrapperStruct("Hashtable_1","")
    //! runtextmacro DeclareParentHashtableWrapperStruct("Hashtable_2","")

    private function onInit takes nothing returns nothing
        set Hashtable_1[0].string[0] = "This is good."
        set Hashtable_2[0].string[0] = "This is better."
        
        call BJDebugMsg(Hashtable_1[0].string[0])
        call BJDebugMsg(Hashtable_2[0].string[0])
    endfunction

endlibrary

//===================================================
// Making this library an optional requirement
//===================================================
// You can easily make this library an optional requirement (user will need to have Table instead).


//! endnovjass

// Declare (copy-and-paste) this textmacro somewhere in your library.
// It's functionally the same as a wrapped hashtable, but it instead wraps a HashTable struct.
// The HashTable struct is declared in Bribe's Table library (after version 4.0.)
// You can declare this textmacro at the very end of your library (order does not matter)
//! textmacro_once DeclareHashTableWrapperModule takes NAME

    module $NAME$_HashTableWrapper
        private static key table
        
        static if LIBRARY_ConstTable then
            static method operator [] takes integer index returns Table
                return ConstHashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call ConstHashTable(table).remove(index)
            endmethod
            
            static method operator ConstHashTable takes nothing returns ConstHashTable
                return table
            endmethod
        else
            static method operator [] takes integer index returns Table
                return HashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call HashTable(table).remove(index)
            endmethod
            
            static method operator HashTable takes nothing returns HashTable
                return table
            endmethod
        endif
    endmodule
//! endtextmacro
                                                                                        
//! novjass
library Example initializer onInit requires optional HashtableWrapper

    globals
        private hashtable wrapperHash = InitHashtable()
    endglobals

    static if LIBRARY_HashtableWrapper then
        //! runtextmacro optional DeclareParentHashtableWrapperModule("wrapperHash","true", "data","private")
    else
        //! runtextmacro DeclareHashTableWrapperModule("data")
    endif

    private struct data extends array
        static if LIBRARY_HashtableWrapper then
            implement optional data_ParentHashtableWrapper
        else
            implement data_HashTableWrapper
        endif
    endstruct

    private function onInit takes nothing returns nothing
        set data[1].string[1] = "Well done."
        call BJDebugMsg(data[1].string[1])
        static if LIBRARY_Table then  // n-dimensional hashtables only supported with Table.
            set data[0][1] = Table.create()
            set data[0][1].string[2] = "Well done."
            call BJDebugMsg(data[0][1].string[2])
        endif
    endfunction
endlibrary
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

//! textmacro DeclareParentHashtableWrapperModule takes HASHTABLE, USE_HANDLES, NAME, ACCESS
private function $NAME$_GetWrappedHashtable takes nothing returns hashtable
    return $HASHTABLE$
endfunction


$ACCESS$ struct $NAME$_reals extends array
    method operator [] takes integer key returns real
        return LoadReal($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method operator []= takes integer key, real value returns nothing
        call SaveReal($NAME$_GetWrappedHashtable(), this, key, value)
    endmethod
    method has takes integer key returns boolean
        return HaveSavedReal($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedReal($NAME$_GetWrappedHashtable(), this, key)
    endmethod
endstruct
$ACCESS$ module $NAME$_realm
    method operator real takes nothing returns $NAME$_reals
        return this
    endmethod
endmodule

$ACCESS$ struct $NAME$_booleans extends array
    method operator [] takes integer key returns boolean
        return LoadBoolean($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method operator []= takes integer key, boolean value returns nothing
        call SaveBoolean($NAME$_GetWrappedHashtable(), this, key, value)
    endmethod
    method has takes integer key returns boolean
        return HaveSavedBoolean($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedBoolean($NAME$_GetWrappedHashtable(), this, key)
    endmethod
endstruct
$ACCESS$ module $NAME$_booleanm
    method operator boolean takes nothing returns $NAME$_booleans
        return this
    endmethod
endmodule

$ACCESS$ struct $NAME$_strings extends array
    method operator [] takes integer key returns string
        return LoadStr($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method operator []= takes integer key, string value returns nothing
        call SaveStr($NAME$_GetWrappedHashtable(), this, key, value)
    endmethod
    method has takes integer key returns boolean
        return HaveSavedString($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedString($NAME$_GetWrappedHashtable(), this, key)
    endmethod
endstruct
$ACCESS$ module $NAME$_stringm
    method operator string takes nothing returns $NAME$_strings
        return this
    endmethod
endmodule

$ACCESS$ struct $NAME$_integers extends array
    method operator [] takes integer key returns integer
        return LoadInteger($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method operator []= takes integer key, integer value returns nothing
        call SaveInteger($NAME$_GetWrappedHashtable(), this, key, value)
    endmethod
    method has takes integer key returns boolean
        return HaveSavedInteger($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedInteger($NAME$_GetWrappedHashtable(), this, key)
    endmethod
endstruct
$ACCESS$ module $NAME$_integerm
    method operator integer takes nothing returns $NAME$_integers
        return this
    endmethod
endmodule

private struct $NAME$_handles extends array
    method has takes integer key returns boolean
        return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
    endmethod
endstruct

static if  $USE_HANDLES$ then
    private struct $NAME$_agents extends array
        method operator []= takes integer key, agent value returns nothing
            call SaveAgentHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
    endstruct

    $ACCESS$ struct $NAME$_players extends array
        method operator [] takes integer key returns player
            return LoadPlayerHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, player value returns nothing
            call SavePlayerHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_playerm
        method operator player takes nothing returns $NAME$_players
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_widgets extends array
        method operator [] takes integer key returns widget
            return LoadWidgetHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, widget value returns nothing
            call SaveWidgetHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_widgetm
        method operator widget takes nothing returns $NAME$_widgets
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_destructables extends array
        method operator [] takes integer key returns destructable
            return LoadDestructableHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, destructable value returns nothing
            call SaveDestructableHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_destructablem
        method operator destructable takes nothing returns $NAME$_destructables
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_items extends array
        method operator [] takes integer key returns item
            return LoadItemHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, item value returns nothing
            call SaveItemHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_itemm
        method operator item takes nothing returns $NAME$_items
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_units extends array
        method operator [] takes integer key returns unit
            return LoadUnitHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, unit value returns nothing
            call SaveUnitHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_unitm
        method operator unit takes nothing returns $NAME$_units
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_abilitys extends array
        method operator [] takes integer key returns ability
            return LoadAbilityHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, ability value returns nothing
            call SaveAbilityHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_abilitym
        method operator ability takes nothing returns $NAME$_abilitys
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_timers extends array
        method operator [] takes integer key returns timer
            return LoadTimerHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, timer value returns nothing
            call SaveTimerHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_timerm
        method operator timer takes nothing returns $NAME$_timers
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_triggers extends array
        method operator [] takes integer key returns trigger
            return LoadTriggerHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, trigger value returns nothing
            call SaveTriggerHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_triggerm
        method operator trigger takes nothing returns $NAME$_triggers
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_triggerconditions extends array
        method operator [] takes integer key returns triggercondition
            return LoadTriggerConditionHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, triggercondition value returns nothing
            call SaveTriggerConditionHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_triggerconditionm
        method operator triggercondition takes nothing returns $NAME$_triggerconditions
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_triggeractions extends array
        method operator [] takes integer key returns triggeraction
            return LoadTriggerActionHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, triggeraction value returns nothing
            call SaveTriggerActionHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_triggeractionm
        method operator triggeraction takes nothing returns $NAME$_triggeractions
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_events extends array
        method operator [] takes integer key returns event
            return LoadTriggerEventHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, event value returns nothing
            call SaveTriggerEventHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_eventm
        method operator event takes nothing returns $NAME$_events
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_forces extends array
        method operator [] takes integer key returns force
            return LoadForceHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, force value returns nothing
            call SaveForceHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_forcem
        method operator force takes nothing returns $NAME$_forces
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_groups extends array
        method operator [] takes integer key returns group
            return LoadGroupHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, group value returns nothing
            call SaveGroupHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_groupm
        method operator group takes nothing returns $NAME$_groups
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_locations extends array
        method operator [] takes integer key returns location
            return LoadLocationHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, location value returns nothing
            call SaveLocationHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_locationm
        method operator location takes nothing returns $NAME$_locations
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_rects extends array
        method operator [] takes integer key returns rect
            return LoadRectHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, rect value returns nothing
            call SaveRectHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_rectm
        method operator rect takes nothing returns $NAME$_rects
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_boolexprs extends array
        method operator [] takes integer key returns boolexpr
            return LoadBooleanExprHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, boolexpr value returns nothing
            call SaveBooleanExprHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_boolexprm
        method operator boolexpr takes nothing returns $NAME$_boolexprs
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_sounds extends array
        method operator [] takes integer key returns sound
            return LoadSoundHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, sound value returns nothing
            call SaveSoundHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_soundm
        method operator sound takes nothing returns $NAME$_sounds
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_effects extends array
        method operator [] takes integer key returns effect
            return LoadEffectHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, effect value returns nothing
            call SaveEffectHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_effectm
        method operator effect takes nothing returns $NAME$_effects
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_unitpools extends array
        method operator [] takes integer key returns unitpool
            return LoadUnitPoolHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, unitpool value returns nothing
            call SaveUnitPoolHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_unitpoolm
        method operator unitpool takes nothing returns $NAME$_unitpools
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_itempools extends array
        method operator [] takes integer key returns itempool
            return LoadItemPoolHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, itempool value returns nothing
            call SaveItemPoolHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_itempoolm
        method operator itempool takes nothing returns $NAME$_itempools
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_quests extends array
        method operator [] takes integer key returns quest
            return LoadQuestHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, quest value returns nothing
            call SaveQuestHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_questm
        method operator quest takes nothing returns $NAME$_quests
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_questitems extends array
        method operator [] takes integer key returns questitem
            return LoadQuestItemHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, questitem value returns nothing
            call SaveQuestItemHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_questitemm
        method operator questitem takes nothing returns $NAME$_questitems
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_defeatconditions extends array
        method operator [] takes integer key returns defeatcondition
            return LoadDefeatConditionHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, defeatcondition value returns nothing
            call SaveDefeatConditionHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_defeatconditionm
        method operator defeatcondition takes nothing returns $NAME$_defeatconditions
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_timerdialogs extends array
        method operator [] takes integer key returns timerdialog
            return LoadTimerDialogHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, timerdialog value returns nothing
            call SaveTimerDialogHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_timerdialogm
        method operator timerdialog takes nothing returns $NAME$_timerdialogs
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_leaderboards extends array
        method operator [] takes integer key returns leaderboard
            return LoadLeaderboardHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, leaderboard value returns nothing
            call SaveLeaderboardHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_leaderboardm
        method operator leaderboard takes nothing returns $NAME$_leaderboards
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_multiboards extends array
        method operator [] takes integer key returns multiboard
            return LoadMultiboardHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, multiboard value returns nothing
            call SaveMultiboardHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_multiboardm
        method operator multiboard takes nothing returns $NAME$_multiboards
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_multiboarditems extends array
        method operator [] takes integer key returns multiboarditem
            return LoadMultiboardItemHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, multiboarditem value returns nothing
            call SaveMultiboardItemHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_multiboarditemm
        method operator multiboarditem takes nothing returns $NAME$_multiboarditems
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_trackables extends array
        method operator [] takes integer key returns trackable
            return LoadTrackableHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, trackable value returns nothing
            call SaveTrackableHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_trackablem
        method operator trackable takes nothing returns $NAME$_trackables
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_dialogs extends array
        method operator [] takes integer key returns dialog
            return LoadDialogHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, dialog value returns nothing
            call SaveDialogHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_dialogm
        method operator dialog takes nothing returns $NAME$_dialogs
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_buttons extends array
        method operator [] takes integer key returns button
            return LoadButtonHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, button value returns nothing
            call SaveButtonHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_buttonm
        method operator button takes nothing returns $NAME$_buttons
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_texttags extends array
        method operator [] takes integer key returns texttag
            return LoadTextTagHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, texttag value returns nothing
            call SaveTextTagHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_texttagm
        method operator texttag takes nothing returns $NAME$_texttags
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_lightnings extends array
        method operator [] takes integer key returns lightning
            return LoadLightningHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, lightning value returns nothing
            call SaveLightningHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_lightningm
        method operator lightning takes nothing returns $NAME$_lightnings
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_images extends array
        method operator [] takes integer key returns image
            return LoadImageHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, image value returns nothing
            call SaveImageHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_imagem
        method operator image takes nothing returns $NAME$_images
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_ubersplats extends array
        method operator [] takes integer key returns ubersplat
            return LoadUbersplatHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, ubersplat value returns nothing
            call SaveUbersplatHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_ubersplatm
        method operator ubersplat takes nothing returns $NAME$_ubersplats
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_regions extends array
        method operator [] takes integer key returns region
            return LoadRegionHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, region value returns nothing
            call SaveRegionHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_regionm
        method operator region takes nothing returns $NAME$_regions
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_fogstates extends array
        method operator [] takes integer key returns fogstate
            return LoadFogStateHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, fogstate value returns nothing
            call SaveFogStateHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_fogstatem
        method operator fogstate takes nothing returns $NAME$_fogstates
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_fogmodifiers extends array
        method operator [] takes integer key returns fogmodifier
            return LoadFogModifierHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, fogmodifier value returns nothing
            call SaveFogModifierHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_fogmodifierm
        method operator fogmodifier takes nothing returns $NAME$_fogmodifiers
            return this
        endmethod
    endmodule

    $ACCESS$ struct $NAME$_hashtables extends array
        method operator [] takes integer key returns hashtable
            return LoadHashtableHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method operator []= takes integer key, hashtable value returns nothing
            call SaveHashtableHandle($NAME$_GetWrappedHashtable(), this, key, value)
        endmethod
        method has takes integer key returns boolean
            return HaveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
        method remove takes integer key returns nothing
            call RemoveSavedHandle($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endstruct
    $ACCESS$ module $NAME$_hashtablem
        method operator hashtable takes nothing returns $NAME$_hashtables
            return this
        endmethod
    endmodule
endif

$ACCESS$ struct $NAME$_Child extends array
    
    implement $NAME$_realm
    implement $NAME$_integerm
    implement $NAME$_booleanm
    implement $NAME$_stringm
    
    static if $USE_HANDLES$ then
        method operator handle takes nothing returns $NAME$_handles
            return this
        endmethod
    
        method operator agent takes nothing returns $NAME$_agents
            return this
        endmethod

        implement $NAME$_playerm
        implement $NAME$_widgetm
        implement $NAME$_destructablem
        implement $NAME$_itemm
        implement $NAME$_unitm
        implement $NAME$_abilitym
        implement $NAME$_timerm
        implement $NAME$_triggerm
        implement $NAME$_triggerconditionm
        implement $NAME$_triggeractionm
        implement $NAME$_eventm
        implement $NAME$_forcem
        implement $NAME$_groupm
        implement $NAME$_locationm
        implement $NAME$_rectm
        implement $NAME$_boolexprm
        implement $NAME$_soundm
        implement $NAME$_effectm
        implement $NAME$_unitpoolm
        implement $NAME$_itempoolm
        implement $NAME$_questm
        implement $NAME$_questitemm
        implement $NAME$_defeatconditionm
        implement $NAME$_timerdialogm
        implement $NAME$_leaderboardm
        implement $NAME$_multiboardm
        implement $NAME$_multiboarditemm
        implement $NAME$_trackablem
        implement $NAME$_dialogm
        implement $NAME$_buttonm
        implement $NAME$_texttagm
        implement $NAME$_lightningm
        implement $NAME$_imagem
        implement $NAME$_ubersplatm
        implement $NAME$_regionm
        implement $NAME$_fogstatem
        implement $NAME$_fogmodifierm
        implement $NAME$_hashtablem
    endif
   
    static if LIBRARY_Table then
        method operator [] takes integer key returns Table
            return LoadInteger($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    else
        method operator [] takes integer key returns integer
            return LoadInteger($NAME$_GetWrappedHashtable(), this, key)
        endmethod
    endif
   
    method operator []= takes integer key, integer tb returns nothing
        call SaveInteger($NAME$_GetWrappedHashtable(), this, key, tb)
    endmethod
   
    method has takes integer key returns boolean
        return HaveSavedInteger($NAME$_GetWrappedHashtable(), this, key)
    endmethod
   
    method remove takes integer key returns nothing
        call RemoveSavedInteger($NAME$_GetWrappedHashtable(), this, key)
    endmethod
   
    method flush takes nothing returns nothing
        call FlushChildHashtable($NAME$_GetWrappedHashtable(), this)
    endmethod
endstruct

private module $NAME$_ParentHashtableWrapper
    static method operator[] takes integer key returns $NAME$_Child
        return key
    endmethod
    
    static method flushChild takes integer key returns nothing
        call FlushChildHashtable($NAME$_GetWrappedHashtable(), key)
    endmethod
    
    static method flush takes nothing returns nothing
        call FlushParentHashtable($NAME$_GetWrappedHashtable())
    endmethod
    
    static method hashtable takes nothing returns hashtable
        return $NAME$_GetWrappedHashtable()
    endmethod
endmodule
//! endtextmacro
endlibrary