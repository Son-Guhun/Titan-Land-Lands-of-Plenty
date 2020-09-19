/*
This trigger works in two key phases:

1) During map initialization, enumerate all existing units of all players to give them an index.
2) Adds a second event to itself to index new units as they enter the map.

As a unit enters the map, check for any old units that may have been removed at some point in order to free their index.
*/

library UnitIndexer requires WorldBounds, DecoOnEnterMap
/* Original library by Bribe

Converted to JASS and customized by Guhun. */

globals
    private integer udg_UDexWasted = 0
    private integer udg_UDexRecycle = 0
    private integer udg_UDexGen = 0
endglobals

// Added by Guhun. This function is used to avoid recycling multiple times in the same frame when many units are created simultaneously.
private function RecycleIndexes takes nothing returns nothing
    local integer pdex = udg_UDex
    local integer ndex

    set udg_UDexWasted = 0
    set udg_UDex = udg_UDexNext[0]
    loop
        exitwhen udg_UDex == 0
        if ( GetUnitUserData(udg_UDexUnits[udg_UDex]) == 0 ) then
            //  
            // Remove index from linked list
            //  
            set ndex = udg_UDexNext[udg_UDex]
            set udg_UDexNext[udg_UDexPrev[udg_UDex]] = ndex
            set udg_UDexPrev[ndex] = udg_UDexPrev[udg_UDex]
            set udg_UDexPrev[udg_UDex] = 0
            set udg_IsUnitPreplaced[udg_UDex] = false
            //  
            // Fire deindex event for UDex
            //  
            set udg_UnitIndexEvent = 2.00
            set udg_UnitIndexEvent = 0.00
            //  
            // Recycle the index for later use
            //  
            set udg_UDexUnits[udg_UDex] = null
            set udg_UDexNext[udg_UDex] = udg_UDexRecycle
            set udg_UDexRecycle = udg_UDex
            set udg_UDex = ndex
        else
            set udg_UDex = udg_UDexNext[udg_UDex]
        endif
    endloop
    
    set udg_UDex = pdex
    call DestroyTimer(GetExpiredTimer())
endfunction


private function IndexUnit takes nothing returns boolean
    local unit u = GetFilterUnit()
    local integer pdex = udg_UDex
    if ( udg_IsUnitPreplaced[0] == false ) then
        //  
        // Check for removed units for every (32) new units created
        //  
        set udg_UDexWasted = ( udg_UDexWasted + 1 )
        if ( udg_UDexWasted == 32 ) then
            call TimerStart(CreateTimer(), 1., false, function RecycleIndexes)
        endif
    endif
    //  
    // You can use the boolean UnitIndexerEnabled to protect some of your undesirable units from being indexed
    // - Example:
    // -- Set UnitIndexerEnabled = False
    // -- Unit - Create 1 Dummy for (Triggering player) at TempLoc facing 0.00 degrees
    // -- Set UnitIndexerEnabled = True
    //  
    // You can also customize the following block - if conditions are false the (Matching unit) won't be indexed.
    // 
    //IF UNIT AS DECORATION ABILITY, DO NOT INDEX THIS UNIT
    if LoP_IsUnitDecoration(u) then
        call SetUnitUserData(u, 0)
        call DecoOnEnterMap(u)
        set u = null
        return false
    endif
    if ( udg_UnitIndexerEnabled == true and  GetUnitUserData(u) == 0) then
        //  
        // Generate a unique integer index for this unit
        //  
        if ( udg_UDexRecycle == 0 ) then
            set udg_UDex = ( udg_UDexGen + 1 )
            set udg_UDexGen = udg_UDex
        else
            set udg_UDex = udg_UDexRecycle
            set udg_UDexRecycle = udg_UDexNext[udg_UDex]
        endif
        //  
        // Link index to unit, unit to index
        //  
        set udg_UDexUnits[udg_UDex] = u
        call SetUnitUserData( udg_UDexUnits[udg_UDex], udg_UDex )
        set udg_IsUnitPreplaced[udg_UDex] = udg_IsUnitPreplaced[0]
        //  
        // Use a doubly-linked list to store all active indexes
        //  
        set udg_UDexPrev[udg_UDexNext[0]] = udg_UDex
        set udg_UDexNext[udg_UDex] = udg_UDexNext[0]
        set udg_UDexNext[0] = udg_UDex
        //  
        // Fire index event for UDex
        //  
        set udg_UnitIndexEvent = 0.00
        set udg_UnitIndexEvent = 1.00
        set udg_UnitIndexEvent = 0.00
    endif
    set udg_UDex = pdex
    set u = null
    return false
endfunction

// ~Guhun: Added WolrdBounds requirement in order to avoid creating multiple map-sized regions.
private function InitializeUnitIndexer takes nothing returns nothing
    local integer i = 0
    local boolexpr b = Filter(function IndexUnit)
    set udg_UnitIndexEvent = -1.00
    set udg_UnitIndexerEnabled = true
    set udg_IsUnitPreplaced[0] = true
    call TriggerRegisterEnterRegion(CreateTrigger(), WorldBounds.worldRegion, b)
    loop
        call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), b)
        set i = i + 1
        exitwhen i == bj_MAX_PLAYER_SLOTS
    endloop
    set b = null
    //  
    // This is the "Unit Indexer Initialized" event, use it instead of "Map Initialization" for best results
    //  
    set udg_IsUnitPreplaced[0] = false
    set udg_UnitIndexEvent = 3.00
endfunction

//===========================================================================
function InitTrig_Unit_Indexer takes nothing returns nothing
    call InitializeUnitIndexer()
endfunction

endlibrary

