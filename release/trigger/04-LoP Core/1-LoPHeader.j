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

//! textmacro ForUnitInGroup takes UNIT, GROUP
    set $UNIT$ = FirstOfGroup($GROUP$)
    if $UNIT$ == null then
        if BlzGroupGetSize($GROUP$) > 0 then
            call GroupRefresh($GROUP$)
            set $UNIT$ = FirstOfGroup($GROUP$)
            exitwhen $UNIT$ == null
        else
            exitwhen true
        endif
    endif
    call GroupRemoveUnit($GROUP$, $UNIT$)
//! endtextmacro

function ExecuteCode takes code callback returns nothing
    call ForForce(bj_FORCE_PLAYER[0], callback)
endfunction

function LoP_TransportHasUnits takes unit transport returns boolean
    return not IsGroupEmpty(udg_CargoTransportGroup[GetUnitUserData(transport)])
endfunction

endlibrary
