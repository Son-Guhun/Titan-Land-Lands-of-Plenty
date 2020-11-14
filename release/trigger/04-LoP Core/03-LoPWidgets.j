library LoPWidgets requires LoPHeader, TableStruct, POWER, HERO, optional TerrainEditorUI
/* 
    This libary defines many utilities for widget objects in the map's script. The POWER and HERO
libraries are defined at the end of this file.
    
    struct LoP_UnitData:
        Fields:
            boolean isHeroic -> this field is used by heroic units so that they can be easily recognized as heroic. It should never be set to false, if it had been set to true.
            boolean hideOnDeselect -> whether a unit should be hidden upon being deselected.
            
        Methods:
            nothing destroy() -> must be called when a unit is removed from the game.
            
            Static:
                LoP_UnitDataget get(unit whichUnit)  -> get an instance of this struct for a unit (handle id)
                
    Constant Functions:
    
        . Titan powers:
        .   unit POWER_INVULNERABILITY()
        .   unit POWER_VULNERABILITY()
        .   unit POWER_KILL()
        .   unit POWER_LEVEL()
        .   unit POWER_DELEVEL()
        .   unit POWER_REMOVE()
        
        . Special heroes:
        .   unit HERO_COSMOSIS()
        .   unit HERO_CREATOR()
    
    Functions:
    
        boolean LoP_IsUnitHero(unit u)
        boolean LoP_IsUnitDecoBuilder(unit u)
        boolean LoP_IsUnitProtected(unit u)  -> protected units can't be removed or killed.
        boolean LoP_IsUnitDummy(unit u)  -> dummy units are used by abilities.
        
        group LoP_GetProtectedUnits() -> returns the group which contains protected units.
        
        nothing LoP_InitProtectedUnits() -> should be called after Deco Tents are created.
*/

private struct Globals extends array
    //! runtextmacro TableStruct_NewConstTableField("","destructablesTab")
endstruct

// ==============================================
// Destructable Utilities

function LoP_IsDestructableProtected takes destructable dest returns boolean
    return Globals.destructablesTab.boolean.has(GetHandleId(dest))
endfunction

function LoP_ProtectDestructable takes destructable dest returns nothing
    set Globals.destructablesTab.boolean[GetHandleId(dest)] = true
endfunction

// ==============================================
// Unit Utilities

struct LoP_UnitData extends array
    /*
        This struct is used to retrieve unit data that is tied to the unit's Handle Id.
    */
    static method get takes unit whichUnit returns LoP_UnitData
        return GetHandleId(whichUnit)
    endmethod

    // This field is used by heroic units so that they can be easily recognized as heroic. It should never be set to false, if it had been set to true.
    //! runtextmacro TableStruct_NewPrimitiveField("isHeroic","boolean")
    
    // //! runtextmacro TableStruct_NewBooleanFieldWithDefault("hideOnDeselect","false")
    //! runtextmacro TableStruct_NewPrimitiveField("hideOnDeselect","boolean")
    
    method destroy takes nothing returns nothing
        call .isHeroicClear()
        call .hideOnDeselectClear()
    endmethod
endstruct

function LoP_IsUnitHero takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'AHer') > 0
endfunction

function LoP_IsUnitDecoBuilder takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'A00J') > 0
endfunction

function LoP_IsUnitProtected takes unit whichUnit returns boolean
    return IsUnitInGroup(whichUnit, udg_System_ProtectedGroup)
endfunction

function LoP_IsUnitDummy takes unit whichUnit returns boolean
    return GetUnitPointValue(whichUnit) == 37
endfunction

// Returns a unit group containing all protected units.
function LoP_GetProtectedUnits takes nothing returns group
    return udg_System_ProtectedGroup
endfunction

// ========
// Protected units intialization

// This filter is used during map initialization to enumerate units in the Titan Palace and protect them.
private function LoP_InitProtectedUnitsFilter takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    
    if ( IsUnitType(filterU, UNIT_TYPE_STRUCTURE) and GetOwningPlayer(filterU) == LoP.NEUTRAL_PASSIVE ) /*
        */ or filterU == HERO_COSMOSIS() /*
        */ or filterU == HERO_CREATOR() /*
        */ or filterU == POWER_KILL() /*
        */ or filterU == POWER_REMOVE() /*
        */ or filterU == POWER_VULNERABILITY() /*
        */ or filterU == POWER_INVULNERABILITY() /*
        */ or filterU == POWER_LEVEL() /*
        */ or filterU == POWER_DELEVEL() /*
        */ or GetUnitTypeId(filterU) == 'n000' /* give unit to
        */ then
        set filterU = null
        return true
    endif
    set filterU = null
    return false
endfunction

function LoP_InitProtectedUnits takes nothing returns nothing
    call GroupEnumUnitsInRect(udg_System_ProtectedGroup, gg_rct_Titan_Palace, Filter(function LoP_InitProtectedUnitsFilter))
endfunction

// ========

endlibrary

/* Unit Constants
    
    These libraries define constants that represent units in the map.
*/

// Titan Powers
library POWER
    public function INVULNERABILITY takes nothing returns unit
        return gg_unit_e00B_0405
    endfunction
    
    public function VULNERABILITY takes nothing returns unit
        return gg_unit_e00A_0411
    endfunction
    
    public function KILL takes nothing returns unit
        return gg_unit_e008_0406
    endfunction
    
    public function LEVEL takes nothing returns unit
        return gg_unit_e009_0407
    endfunction
    
    public function DELEVEL takes nothing returns unit
        return gg_unit_e00C_0408
    endfunction
    
    public function REMOVE takes nothing returns unit
        return gg_unit_e007_0410
    endfunction
endlibrary

// Cosmosis and Angel of Creation
library HERO

    public function COSMOSIS takes nothing returns unit
        return gg_unit_H00V_0359
    endfunction
    
    public function CREATOR takes nothing returns unit
        return gg_unit_H00S_0141
    endfunction

endlibrary