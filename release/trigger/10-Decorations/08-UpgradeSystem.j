library UpgradeSystem requires HashStruct

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "private")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","private")

struct UpgradeList extends array

    //! runtextmacro HashStruct_SetHashtableWrapper("hT")
    //! runtextmacro HashStruct_NewReadonlyStructFieldIndexed("first","UpgradeData", "-4")
    //! runtextmacro HashStruct_NewReadonlyStructFieldIndexed("size","UpgradeData", "-1")
    
    method operator [] takes integer i returns integer
        return .tab[i]
    endmethod
    
    static method get takes integer unitType returns thistype
        return thistype(unitType).first
    endmethod
endstruct

struct UpgradeData extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("hT")

    //! runtextmacro HashStruct_NewReadonlyStructFieldIndexed("prev","UpgradeData", "-2")
    //! runtextmacro HashStruct_NewReadonlyStructFieldIndexed("next","UpgradeData", "-3")
    //! runtextmacro HashStruct_NewReadonlyStructFieldIndexed("first","UpgradeData", "-4")
    
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