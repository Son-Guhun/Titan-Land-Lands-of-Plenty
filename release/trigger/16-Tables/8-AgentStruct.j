library AgentStruct requires HashStruct
/*
A library that creates a module to easily attach temporary data to agents/handles.

This is mostly used for attaching data to timers.
*/

globals
    private hashtable hash = InitHashtable()
endglobals  
//! runtextmacro DeclareParentHashtableWrapperModule("hash", "true", "data", "public")
//! runtextmacro DeclareParentHashtableWrapperStruct("data","public")

module AgentStructNoDestroy

    //! runtextmacro HashStruct_SetHashtableWrapper("AgentStruct_data")
    
    static method get takes handle h returns thistype
        return GetHandleId(h)
    endmethod
    
    method flushFields takes nothing returns nothing
        call AgentStruct_data.flushChild(this)
    endmethod

endmodule

module AgentStruct

    implement AgentStructNoDestroy

    method destroy takes nothing returns nothing
        call .flushFields()
    endmethod

endmodule

endlibrary