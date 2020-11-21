library ConstTable requires Table
/*
A library that provides an alternative Hashtable meant to store static Tables.
*/
   
globals
    private hashtable ht = InitHashtable()
endglobals
   
private struct handles extends array
    method has takes integer key returns boolean
        return HaveSavedHandle(ht, this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedHandle(ht, this, key)
    endmethod
endstruct
   
private struct agents extends array
    method operator []= takes integer key, agent value returns nothing
        call SaveAgentHandle(ht, this, key, value)
    endmethod
endstruct
   
//Run these textmacros to include the entire hashtable API as wrappers.
//Don't be intimidated by the number of macros - Vexorian's map optimizer is
//supposed to kill functions which inline (all of these functions inline).
//! runtextmacro NEW_ARRAY_BASIC("Real", "Real", "real")
//! runtextmacro NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
//! runtextmacro NEW_ARRAY_BASIC("String", "Str", "string")
//New textmacro to allow table.integer[] syntax for compatibility with textmacros that might desire it.
//! runtextmacro NEW_ARRAY_BASIC("Integer", "Integer", "integer")
   
//! runtextmacro NEW_ARRAY("Frame", "framehandle")
//! runtextmacro NEW_ARRAY("Player", "player")
//! runtextmacro NEW_ARRAY("Widget", "widget")
//! runtextmacro NEW_ARRAY("Destructable", "destructable")
//! runtextmacro NEW_ARRAY("Item", "item")
//! runtextmacro NEW_ARRAY("Unit", "unit")
//! runtextmacro NEW_ARRAY("Ability", "ability")
//! runtextmacro NEW_ARRAY("Timer", "timer")
//! runtextmacro NEW_ARRAY("Trigger", "trigger")
//! runtextmacro NEW_ARRAY("TriggerCondition", "triggercondition")
//! runtextmacro NEW_ARRAY("TriggerAction", "triggeraction")
//! runtextmacro NEW_ARRAY("TriggerEvent", "event")
//! runtextmacro NEW_ARRAY("Force", "force")
//! runtextmacro NEW_ARRAY("Group", "group")
//! runtextmacro NEW_ARRAY("Location", "location")
//! runtextmacro NEW_ARRAY("Rect", "rect")
//! runtextmacro NEW_ARRAY("BooleanExpr", "boolexpr")
//! runtextmacro NEW_ARRAY("Sound", "sound")
//! runtextmacro NEW_ARRAY("Effect", "effect")
//! runtextmacro NEW_ARRAY("UnitPool", "unitpool")
//! runtextmacro NEW_ARRAY("ItemPool", "itempool")
//! runtextmacro NEW_ARRAY("Quest", "quest")
//! runtextmacro NEW_ARRAY("QuestItem", "questitem")
//! runtextmacro NEW_ARRAY("DefeatCondition", "defeatcondition")
//! runtextmacro NEW_ARRAY("TimerDialog", "timerdialog")
//! runtextmacro NEW_ARRAY("Leaderboard", "leaderboard")
//! runtextmacro NEW_ARRAY("Multiboard", "multiboard")
//! runtextmacro NEW_ARRAY("MultiboardItem", "multiboarditem")
//! runtextmacro NEW_ARRAY("Trackable", "trackable")
//! runtextmacro NEW_ARRAY("Dialog", "dialog")
//! runtextmacro NEW_ARRAY("Button", "button")
//! runtextmacro NEW_ARRAY("TextTag", "texttag")
//! runtextmacro NEW_ARRAY("Lightning", "lightning")
//! runtextmacro NEW_ARRAY("Image", "image")
//! runtextmacro NEW_ARRAY("Ubersplat", "ubersplat")
//! runtextmacro NEW_ARRAY("Region", "region")
//! runtextmacro NEW_ARRAY("FogState", "fogstate")
//! runtextmacro NEW_ARRAY("FogModifier", "fogmodifier")
//! runtextmacro NEW_ARRAY("Hashtable", "hashtable")
   
struct ConstTable extends array
   
    // Implement modules for intuitive syntax (tb.handle; tb.unit; etc.)
    implement realm
    implement integerm
    implement booleanm
    implement stringm
    implement framehandlem
    implement playerm
    implement widgetm
    implement destructablem
    implement itemm
    implement unitm
    implement abilitym
    implement timerm
    implement triggerm
    implement triggerconditionm
    implement triggeractionm
    implement eventm
    implement forcem
    implement groupm
    implement locationm
    implement rectm
    implement boolexprm
    implement soundm
    implement effectm
    implement unitpoolm
    implement itempoolm
    implement questm
    implement questitemm
    implement defeatconditionm
    implement timerdialogm
    implement leaderboardm
    implement multiboardm
    implement multiboarditemm
    implement trackablem
    implement dialogm
    implement buttonm
    implement texttagm
    implement lightningm
    implement imagem
    implement ubersplatm
    implement regionm
    implement fogstatem
    implement fogmodifierm
    implement hashtablem
   
    method operator handle takes nothing returns handles
        return this
    endmethod
   
    method operator agent takes nothing returns agents
        return this
    endmethod
   
    method operator [] takes integer key returns Table
        return LoadInteger(ht, this, key) //return this.integer[key]
    endmethod
   
    method operator []= takes integer key, Table tb returns nothing
        call SaveInteger(ht, this, key, tb) //set this.integer[key] = tb
    endmethod
   
    method has takes integer key returns boolean
        return HaveSavedInteger(ht, this, key) //return this.integer.has(key)
    endmethod
   
    method remove takes integer key returns nothing
        call RemoveSavedInteger(ht, this, key) //call this.integer.remove(key)
    endmethod
   
    method flush takes nothing returns nothing
        call FlushChildHashtable(ht, this)
    endmethod
endstruct


struct ConstHashTable extends array
    //Enables myHash[parentKey][childKey] syntax.
    //Basically, it creates a Table in the place of the parent key if
    //it didn't already get created earlier.
    method operator [] takes integer index returns Table
        local Table t = ConstTable(this)[index]
        if t == 0 then
            set t = Table.create()
            set ConstTable(this)[index] = t
        endif
        return t
    endmethod

    //You need to call this on each parent key that you used if you
    //intend to destroy the HashTable or simply no longer need that key.
    method remove takes integer index returns nothing
        local Table t = ConstTable(this)[index]
        if t != 0 then
            call t.destroy()
            call ConstTable(this).remove(index)
        endif
    endmethod
    
    // Wrapper that conforms to hashtable api
    method flushChild takes integer index returns nothing
        call .remove(index)
    endmethod
   
    method has takes integer index returns boolean
        return ConstTable(this).has(index)
    endmethod
endstruct
endlibrary