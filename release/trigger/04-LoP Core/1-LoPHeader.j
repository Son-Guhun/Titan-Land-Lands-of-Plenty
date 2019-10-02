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
    exitwhen $UNIT$ == null
    call GroupRemoveUnit($GROUP$, $UNIT$)
//! endtextmacro

//! textmacro ForUnitInGroupWhile takes UNIT, GROUP, CONDITION
    set $UNIT$ = FirstOfGroup($GROUP$)
    call GroupRemoveUnit($GROUP$, $UNIT$)
    exitwhen $UNIT$ == null or not $CONDITION$
//! endtextmacro

function ExecuteCode takes code callback returns nothing
    call ForForce(bj_FORCE_PLAYER[0], callback)
endfunction

endlibrary
