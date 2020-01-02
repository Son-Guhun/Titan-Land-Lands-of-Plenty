library PlayerUtils
/**************************************************************
*   Compatible with:
*   v1.2.9 by TriggerHappy
*
*   Modified by:
*   Guhun
*
*   This is a lite version of PlayerUtils whose sole purpose is to define global variables that
*   store the local player and their id. It is a fully compatible subset of the PlayerUtils API.
*
*
*   Struct API
*   -------------------
*     struct User
*
*       static method fromIndex takes integer i returns User
*       static method fromLocal takes nothing returns User
*
*       static method operator []    takes integer id returns User
*
*       method toPlayer takes nothing returns player
*
*       readonly static player Local
*       readonly static integer LocalId
*       readonly player handle
*       readonly integer id
*
**************************************************************/

private keyword Init

struct User extends array
    
    readonly static player Local
    readonly static integer LocalId
    
    method operator handle takes nothing returns player
        return Player(this)
    endmethod
    
    method operator id takes nothing returns integer
        return this
    endmethod
    
    static method fromIndex takes integer index returns thistype
        return index
    endmethod
    
    static method fromLocal takes nothing returns thistype
        return thistype.LocalId
    endmethod
    
    method toPlayer takes nothing returns player
        return .handle
    endmethod
    
    static method operator [] takes player p returns thistype
        return GetPlayerId(p)
    endmethod

    implement Init
endstruct

private module Init
    private static method onInit takes nothing returns nothing
        set .Local = GetLocalPlayer()
        set .LocalId = GetPlayerId(.Local)
    endmethod
endmodule


endlibrary