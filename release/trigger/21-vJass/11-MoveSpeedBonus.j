/* 
A few changes have been made to this library's configurations. Therefore, it will only function properly inside this map.

To have this library function properly anywhere, copy it from:
https://www.hiveworkshop.com/threads/gui-friendly-movement-speed-system-2-0-1.301918/
*/

library MoveSpeedBonus requires optional Table
//////////////////////////////////////////////////////
// Guhun's Move Speed System v2.0.1
//-----------------------------------

//===================================================
// Simple configuration
//===================================================
/*
Just change these numbers to whatever you want, you can also set them to a variable (remember to 
put "udg_" in front of the variable)
*/
function GMSS_GetDefaultMaxSpeed takes nothing returns real

    return 522.0  // Value for Default Maximum Speed

endfunction

function GMSS_GetDefaultMinSpeed takes nothing returns real

    return 0.000  // Value for Default Minimum Speed

endfunction

//===================================================
// Advanced configuration
//===================================================

globals
    // Use a Table instance instead of a Hashtable (requires library: Table https://www.hiveworkshop.com/threads/snippet-new-table.188084/ )
    public constant boolean USE_TABLE = false
    
    // Create a new Hashtable for the system, instead of using an existing one.
    // If this is false, and you are not using GUI, make sure to also change the 2 textmacros below.
    public constant boolean INIT_HASHTABLE = false
    
    // This textmacro returns the Alternate Hashtable when INIT_HASHTABLE is false.
    //! textmacro GMSS_AlternateHashtable
        return udg_Hashtable_2
    //! endtextmacro
    
    // This textmacro returns the integer Key used for storing data when INIT_HASHTABLE is false.
    //! textmacro GMSS_AlternateHashtableKey
        return 'Amov'
    //! endtextmacro
    
    // Automatically clean up unit data by removing any data when a unit is created that has an ID that was previously used
    // If you disable this, then you must call GMSS_ClearData whenever a unit enters the game or is removed from it
    public constant boolean AUTO_CLEANUP = false
endglobals

//! novjass
'                                                                                                  '
'                                            API                                                   '

// Adds "amount" to unit speed bonus and sets move speed between "minSpeed" and "maxSpeed".
function GMSS_UnitAddMoveSpeedEx
    takes 
        unit whichUnit
        real amount   => //!The amount to add to the unit's move speed.
        real minSpeed => //!The unit's new speed will not be lower than this value.
        real maxSpeed => //!The unit's new speed will not be higher than this value.
    returns
        real => //!The unit's flat move speed bonus after changes are applied.
endfunction

// Multiplies unit speed multiplier by "amount" and sets move speed between "minSpeed" and "maxSpeed".
function GMSS_UnitMultiplyMoveSpeedEx
    takes 
        unit whichUnit
        real amount   => //!The amount to add to the unit's move speed.
        real minSpeed => //!The unit's new speed will not be lower than this value.
        real maxSpeed => //!The unit's new speed will not be higher than this value.
    returns
        real => //!The unit's move speed multiplier after changes are applied.
endfunction

// Like GMSS_UnitAddMoveSpeedEx, but min and max values are drawn from GMSS_GetDefaultMax(Min)Speed.
function GMSS_UnitAddMoveSpeed takes unit whichUnit, real amount returns real
    takes 
        unit whichUnit
        real amount   => //!The amount to add to the unit's move speed.
    returns
        real => //!The unit's flat move speed bonus after changes are applied.
endfunction

// Like GMSS_UnitMultiplyMoveSpeedEx, but min and max values are drawn from GMSS_GetDefaultMax(Min)Speed.
function GMSS_UnitMultiplyMoveSpeed takes unit whichUnit, real amount returns real
    takes 
        unit whichUnit
        real amount   => //!The amount to add to the unit's move speed.
    returns
        real => //!The unit's move speed multiplier after changes are applied.
endfunction


function GMSS_UnitGetMoveBonus takes unit whichUnit returns real
    takes 
        unit whichUnit
    returns
        real => //!The unit's movement speed flat bonus.
endfunction

function GMSS_UnitGetMoveMultiplier takes unit whichUnit returns real
    takes 
        unit whichUnit
    returns
        real => //!The unit's movement speed multiplier.
endfunction

// Clears all Hashtable or Table data stored for 'whichUnit' in the system.
// You won't need to call this yourself unless AUTO_CLEANUP is set to false.
function GMSS_ClearData takes unit whichUnit returns nothing
    takes 
        unit whichUnit
    returns 
        nothing
endfunction
'                                                                                                  '
'                                        Source Code                                               '
//! endnovjass

static if LIBRARY_Table and USE_TABLE then
    globals 
        private integer data
    endglobals
elseif INIT_HASHTABLE then
    globals
        private hashtable hashTable = null
    endglobals
endif

static if LIBRARY_Table and USE_TABLE then
else
    function GMSS_GetHashtable takes nothing returns hashtable
        static if INIT_HASHTABLE then
            return hashTable
        else
            //! runtextmacro GMSS_AlternateHashtable()
        endif
    endfunction
endif

//===================================================
// Data Storage Utilities
//===================================================
//Positive Unit Handle ID > Move Bonus
//Negative Unit Handle ID > Move Multiplier

private function KEY takes nothing returns integer
    static if INIT_HASHTABLE then
        return 0
    else
        //! runtextmacro GMSS_AlternateHashtableKey()
    endif
endfunction

private function GetUnitId takes unit whichUnit returns integer
    return GetHandleId(whichUnit)
endfunction

private function LoadMultiplier takes integer uId returns real
    static if LIBRARY_Table and USE_TABLE then
        return Table(data).real[-uId]
    else
        return LoadReal(GMSS_GetHashtable(), KEY(), -uId)
        
    endif
endfunction

private function LoadBonus takes integer uId returns real
    static if LIBRARY_Table and USE_TABLE then
        return Table(data).real[uId]
    else
        return LoadReal(GMSS_GetHashtable(), KEY(),  uId)
    endif
endfunction

private function RemoveMultiplier takes integer uId returns nothing
    static if LIBRARY_Table and USE_TABLE then
        call Table(data).real.remove(-uId)
    else
        call RemoveSavedReal(GMSS_GetHashtable(), KEY(), -uId)
    endif
endfunction

private function RemoveBonus takes integer uId returns nothing
    static if LIBRARY_Table and USE_TABLE then
        call Table(data).real.remove(uId)
    else
        call RemoveSavedReal(GMSS_GetHashtable(), KEY(),  uId)
    endif
endfunction

private function SaveMultiplier takes integer uId, real value returns nothing
    static if LIBRARY_Table and USE_TABLE then
        set Table(data).real[-uId] = value
    else
        call SaveReal(GMSS_GetHashtable(), KEY(), -uId, value)
    endif
endfunction

private function SaveBonus takes integer uId, real value returns nothing
    static if LIBRARY_Table and USE_TABLE then
        set Table(data).real[uId] = value
    else
        call SaveReal(GMSS_GetHashtable(), KEY(),  uId, value)
    endif
endfunction

//===================================================
// API functions
//===================================================

// Adds "amount" to unit speed bonus and sets unit speed between "minSpeed" and "maxSpeed".
function GMSS_UnitAddMoveSpeedEx takes unit whichUnit, real amount, real minSpeed, real maxSpeed returns real
    local integer uId = GetUnitId(whichUnit)
    local real bonus = LoadBonus(uId)
    local real multiplier = LoadMultiplier(uId)
    
    //Fix multiplier for when there is no saved value
    if multiplier == 0 then
        set multiplier = 1
    endif
    
    if amount != 0 then
        //Set new value and save/clear data as necessary
        set bonus = bonus + amount
        
        if bonus < -0.99999 and bonus > 0.00001 then //Consider floating point imprecision when clearing Hashtable data
            call RemoveBonus(uId)
        else
            call SaveBonus(uId, bonus)
        endif
    endif
    
    //Set Unit Move Speed (any ability modifiers are applied to this after it is set)
    call SetUnitMoveSpeed(whichUnit, RMaxBJ(minSpeed, RMinBJ(maxSpeed, GetUnitDefaultMoveSpeed(whichUnit)*multiplier + bonus)))
    return bonus
endfunction

// Multiplies unit speed multiplier by "amount" and sets unit speed between "minSpeed" and "maxSpeed".
function GMSS_UnitMultiplyMoveSpeedEx takes unit whichUnit, real amount, real minSpeed, real maxSpeed returns real
    local integer uId = GetUnitId(whichUnit)
    local real bonus = LoadBonus(uId)
    local real multiplier = LoadMultiplier(uId)
   
    //Fix multiplier for when there is no saved value
    if multiplier == 0 then
        set multiplier = 1
    endif   
   
    if amount == 1 or amount <= 0 then
    else
        //Set new value and save/clear data as necessary
        set multiplier = multiplier * amount
        
        if multiplier < 1.00001 and multiplier > 0.99999 then  //Consider floating point imprecision when clearing Hashtable data
            call RemoveMultiplier(uId)
        else
            call SaveMultiplier(uId, multiplier)
        endif
    endif
    
    //Set Unit Move Speed (any ability modifiers are applied to this after it is set)
    call SetUnitMoveSpeed(whichUnit, RMaxBJ(minSpeed, RMinBJ(maxSpeed, GetUnitDefaultMoveSpeed(whichUnit)*multiplier + bonus)))
    return multiplier
endfunction

// Like GMSS_UnitAddMoveSpeedEx, but min and max values are drawn from GMSS_GetDefaultMax(Min)Speed.
function GMSS_UnitAddMoveSpeed takes unit whichUnit, real amount returns real
    return GMSS_UnitAddMoveSpeedEx(whichUnit, amount, GMSS_GetDefaultMinSpeed(), GMSS_GetDefaultMaxSpeed())
endfunction

// Like GMSS_UnitMultiplyMoveSpeedEx, but min and max values are drawn from GMSS_GetDefaultMax(Min)Speed.
function GMSS_UnitMultiplyMoveSpeed takes unit whichUnit, real amount returns real
    return GMSS_UnitMultiplyMoveSpeedEx(whichUnit, amount, GMSS_GetDefaultMinSpeed(), GMSS_GetDefaultMaxSpeed())
endfunction


function GMSS_UnitGetMoveBonus takes unit whichUnit returns real
    return LoadBonus(GetUnitId(whichUnit))
endfunction


function GMSS_UnitGetMoveMultiplier takes unit whichUnit returns real
    local real multiplier = LoadMultiplier(GetUnitId(whichUnit))
    if multiplier == 0 then
        return 1.0
    endif
    return multiplier
endfunction

// Clears all Hashtable or Table data stored for 'whichUnit' in the system.
function GMSS_ClearData takes unit whichUnit returns nothing
    local integer uId = GetHandleId(whichUnit)

    call RemoveBonus(uId)
    call RemoveMultiplier(uId)
endfunction

//===================================================
// Auto Cleanup and Initialization
//===================================================
static if AUTO_CLEANUP then
    private function TrigCleanupCondition takes nothing returns boolean
        call GMSS_ClearData(GetTriggerUnit())
        return false
    endfunction
endif


private module Init
    static method onInit takes nothing returns nothing
        local trigger trig
    
        static if LIBRARY_Table and USE_TABLE then
            set data = Table.create()
        elseif INIT_HASHTABLE then
            set hashTable = InitHashtable()
        endif
        
        static if AUTO_CLEANUP then
            set trig = CreateTrigger()
            call TriggerRegisterEnterRectSimple(trig, GetWorldBounds())
            call TriggerAddCondition(trig, Condition(function TrigCleanupCondition))
            set trig = null
        endif
    endmethod
endmodule
//! textmacro GMSS_Initialization takes GLOBE
private struct Initializer$GLOBE$ extends array
    implement Init
endstruct
//! endtextmacro

// This trick is used because you can't have two structs with the same name, even inside an unused static if.
static if LIBRARY_Table and USE_TABLE then
    //! runtextmacro GMSS_Initialization("1")  
elseif AUTO_CLEANUP then
    //! runtextmacro GMSS_Initialization("2")
elseif INIT_HASHTABLE then
    //! runtextmacro GMSS_Initialization("3")
endif


endlibrary