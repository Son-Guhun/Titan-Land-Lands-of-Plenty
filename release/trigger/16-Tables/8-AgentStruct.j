library AgentStruct requires HashStruct

globals
    private hashtable hash
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

struct testing extends array
    
    implement AgentStruct

endstruct

endlibrary