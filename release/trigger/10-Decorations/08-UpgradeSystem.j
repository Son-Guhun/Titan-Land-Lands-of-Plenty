library UpgradeSystem

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "private")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","private")

struct UpgradeData extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("hT")

    //! runtextmacro HashStruct_NewReadonlyStructField("prev","UpgradeData")
    //! runtextmacro HashStruct_NewReadonlyStructField("next","UpgradeData")
    //! runtextmacro HashStruct_NewReadonlyStructField("first","UpgradeData")
    
    static method get takes unit whichUnit returns integer
        return GetUnitTypeId(whichUnit)
    endmethod
    
    method hasUpgrades takes nothing returns boolean
        return .next_exists()
    endmethod
    
    method hasPrev takes nothing returns boolean
        return .prev_exists()
    endmethod
    
    implement UpgradeSystemInit_Module
endstruct

endlibrary