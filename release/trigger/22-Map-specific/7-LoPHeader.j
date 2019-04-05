library LoPHeader requires UserDefinedRects
function LoP_IsUnitDecoration takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'A0C6') > 0
endfunction

function LoP_PlayerOwnsUnit takes player whichPlayer, unit whichUnit returns boolean
    local player p = GetOwningPlayer(whichUnit)
    
    if p == whichPlayer then
        return true
    endif
    return IsUnitInGroup(whichUnit, udg_System_NeutralUnits[GetPlayerId(whichPlayer)]) and p == Player(PLAYER_NEUTRAL_PASSIVE)
endfunction

function IsGroupEmpty takes group whichGroup returns boolean
    local unit firstUnit = FirstOfGroup(whichGroup)
    
    // If unit was removed from the game, refresh the group
    if GetUnitTypeId(firstUnit) == 0 then
        call GroupRefresh(whichGroup)
        set firstUnit = FirstOfGroup(whichGroup)
    endif
    
    if firstUnit != null then
        set firstUnit = null
        return false
    endif
    
    return true
endfunction

function Commands_GetArguments takes nothing returns string
    return SubString(GetEventPlayerChatString(), StringLength(GetEventPlayerChatStringMatched()), StringLength(GetEventPlayerChatString()))
endfunction

function Commands_StartsWithCommand takes nothing returns boolean
    return SubString(GetEventPlayerChatString(), 0, StringLength(GetEventPlayerChatStringMatched())) == GetEventPlayerChatStringMatched()
endfunction

function Commands_EnumSelectedCheckForGenerator takes group whichGroup, player whichPlayer, boolexpr filter returns integer
    call GroupEnumUnitsSelected(whichGroup, whichPlayer, filter)
    return GUDR_SwapGroup_UnitsInsideUDR(whichGroup, false, null)
endfunction

function Commands_GetChatMessagePlayerNumber takes string str returns integer
    local integer s2i = S2I(str)
    local integer strHash
    if  s2i == 0 then//and str != "0" then
        set strHash = StringHash(str)
        if HaveSavedInteger(udg_Hashtable_1, 0, strHash) then
            return LoadInteger(udg_Hashtable_1, 0, strHash)
        endif
    endif
    return s2i
endfunction

function PlayerNumberIsNotExtraOrVictim takes integer ID returns boolean
    return (ID <= bj_MAX_PLAYERS or ID == PLAYER_NEUTRAL_AGGRESSIVE+1 or ID == PLAYER_NEUTRAL_PASSIVE+1) and (ID >= 1)
endfunction

function PlayerNumberIsNotNeutral takes integer ID returns boolean
    return ID <= bj_MAX_PLAYERS and ID > 0
endfunction

function CheckCommandOverflow takes nothing returns boolean
    if udg_Commands_Counter < udg_Commands_Counter_Max then
        set udg_Commands_Counter = ( udg_Commands_Counter + 1 )
        return true
    elseif udg_Commands_Counter == udg_Commands_Counter_Max then
        call DisplayTextToPlayer( GetTriggerPlayer(), 0, 0, "Command Overflow! Execution stopped.\n Run the command again until it is finished.")
        set udg_Commands_Counter = ( udg_Commands_Counter + 1 )
    endif
    return false
endfunction

function Commands_SetMaximumExecutions takes integer max returns nothing
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = max
endfunction

function Commands_CheckOverflow takes nothing returns boolean
    return CheckCommandOverflow()
endfunction
endlibrary
