library LoPHeader requires TransportUtils
/*
This library defines many functions that are used across the map's code.

*/

struct LoPHeader extends array

    private static constant player neutPassive = Player(PLAYER_NEUTRAL_PASSIVE)
    
    static method operator NEUTRAL_PASSIVE takes nothing returns player
        return neutPassive
    endmethod
    
    static method operator gameMaster takes nothing returns player
        return udg_GAME_MASTER
    endmethod
    
    static method operator gameMaster= takes player p returns nothing
        set udg_GAME_MASTER = p
    endmethod
    
endstruct

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

//! textmacro ForUnitInGroupCountedReverse takes UNIT, INTEGER, GROUP
    exitwhen $INTEGER$ <= 0
    set $INTEGER$ = $INTEGER$ - 1
    set $UNIT$ = BlzGroupUnitAt($GROUP$, $INTEGER$)
    if $UNIT$ == null then
        loop
            set $INTEGER$ = $INTEGER$ - 1
            set $UNIT$ = BlzGroupUnitAt($GROUP$, $INTEGER$)
            exitwhen $UNIT$ != null or $INTEGER$ <= 0
        endloop
        exitwhen $INTEGER$ <= 0
    endif
//! endtextmacro

function ExecuteCode takes code callback returns nothing
    call ForForce(bj_FORCE_PLAYER[0], callback)
endfunction

function LoP_TransportHasUnits takes unit transport returns boolean
    return not IsGroupEmpty(GetTransportedUnits(transport))
endfunction

endlibrary
