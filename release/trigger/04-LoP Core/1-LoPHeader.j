library LoPHeader
/*
This library defines many functions that are used across the map's code.

*/

function LoP_IsUnitDecoration takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'A0C6') > 0
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

endlibrary
