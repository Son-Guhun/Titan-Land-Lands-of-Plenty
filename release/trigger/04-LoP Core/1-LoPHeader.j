library LoPHeader
/*
This library defines many functions that are used across the map's code.

*/

function LoP_IsUnitDecoration takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'A0C6') > 0
endfunction

function IsGroupEmpty takes group whichGroup returns boolean
    return BlzGroupGetSize(whichGroup) == 0
endfunction

endlibrary
