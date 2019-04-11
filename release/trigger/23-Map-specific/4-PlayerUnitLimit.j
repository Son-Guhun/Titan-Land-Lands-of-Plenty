library PlayerUnitLimit
//////////////////////////////////////////////////////
//Player Army Limit System
//0->clear 1->ground 2->flyer 3-> passive

// This system keeps track of the number of units a player currently has on the map.
// Whenever a unit enters the map, you must register it using this system.
// Whenever you wish to unregister a unit, you must call the deregistering functions in this system.

// Units created over the imposed threshold are automatically removed from the game!

// In Titan Land LoP, the registering and deregistering of units is controlled by the Cleanup and 
// Unit Limit System triggers inside the Map System Category.
//////////////////////////////////////////////////////
globals
    public constant integer GROUND = 1
    public constant integer AIR = 2
    public constant integer PASSIVE = 3
endglobals


function Limit_GetPlayerCategoryCount takes integer playerId, integer unitCategory returns integer
    return udg_System_PlayerArmy[playerId + bj_MAX_PLAYER_SLOTS*(unitCategory - 1)]
endfunction

function Limit_SetPlayerCategoryCount takes integer playerId, integer unitCategory, integer x returns nothing
    set udg_System_PlayerArmy[playerId + bj_MAX_PLAYER_SLOTS*(unitCategory - 1)]  = x
endfunction

function Limit_SaveUnitCategory takes integer unitUserData, integer unitCategory returns nothing
    set udg_System_LimitUnitCategory[unitUserData] = unitCategory
endfunction

function Limit_LoadUnitCategory takes integer unitUserData returns integer
    return udg_System_LimitUnitCategory[unitUserData]
endfunction

constant function Limit_GetCategoryName takes integer category returns string
    if category == GROUND then
        return "Ground Units"
    elseif category == AIR then
        return "Air Units"
    else
        return "Passive Units"
    endif
endfunction

function Limit_UnitCategory takes unit u returns integer
    if IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER) or IsUnitType(u, UNIT_TYPE_RANGED_ATTACKER) then
        if IsUnitType(u, UNIT_TYPE_FLYING) then
            return AIR  //Register Flying Unit
        else
            return GROUND  //Register Army Unit
        endif
    else
        return PASSIVE  //Register Passive Unit
    endif
endfunction

//===========================================================================
// API
//===========================================================================

function Limit_IsPlayerLimited takes player whichPlayer returns boolean
    return whichPlayer != Player(PLAYER_NEUTRAL_PASSIVE)
endfunction

function Limit_IsUnitLimited takes unit whichUnit returns boolean
    return not IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE)
endfunction

function Limit_RegisterUnit takes unit newU returns nothing
    local player owner = GetOwningPlayer(newU)
    local integer ownerID = GetPlayerId(owner)
    local integer unitCategory
    local integer count

    //Figure out the unit's category
    set unitCategory = Limit_UnitCategory(newU)
    debug call BJDebugMsg("Debug message: " + GetUnitName(newU) + " registered for " + GetPlayerName(owner) + " in " + Limit_GetCategoryName(unitCategory))
    
    //Remove unit if limit has been broken, otherwise register it
    set count = Limit_GetPlayerCategoryCount(ownerID, unitCategory)
    if  count >= udg_System_PArmyLimit[unitCategory] then
        call DisplayTextToPlayer(owner, 0, 0, "Unit has been removed due to limit break. Category: " + Limit_GetCategoryName(unitCategory))
        call RemoveUnit(newU)
    else
        call Limit_SetPlayerCategoryCount(ownerID, unitCategory, count + 1)
        call Limit_SaveUnitCategory(GetUnitUserData(newU), unitCategory)
    endif
endfunction

function Limit_UnregisterUnitEx takes unit oldU, player whichPlayer returns nothing
    local integer unitID = GetUnitUserData(oldU)
    local integer unitCategory = Limit_LoadUnitCategory(unitID)
    local integer playerId

    // Default to unit owner if provided player parameter is null.
    if whichPlayer == null then
        set playerId = GetPlayerId(GetOwningPlayer(oldU))
    else
        set playerId = GetPlayerId(whichPlayer)
    endif
    
    call Limit_SaveUnitCategory(unitID , 0)
    
    debug call Debug_PrintIf(unitCategory == 0, "Limit: Unregister function called on " + GetUnitName(oldU) + ", which was never registered!")
    call Limit_SetPlayerCategoryCount(playerId, unitCategory, Limit_GetPlayerCategoryCount(playerId, unitCategory) - 1)

    debug call BJDebugMsg("Debug message: " + GetUnitName(oldU) + " UNregistered for " + GetPlayerName(Player(playerId)) + " in " + Limit_GetCategoryName(unitCategory))
endfunction

function Limit_UnregisterUnit takes unit oldU returns nothing
    call Limit_UnregisterUnitEx(oldU, null)
endfunction

endlibrary