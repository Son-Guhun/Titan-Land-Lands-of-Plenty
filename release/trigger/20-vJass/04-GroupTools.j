/***************************************
*
*   GroupTools
*   v1.1.2.2
*   By Magtheridon96
*
*   - Original version by Rising_Dusk
*
*   - Recycles groups, and allows the
*   enumeration of units while taking
*   into account collision.
*
*   API:
*   ----
*
*       - group ENUM_GROUP
*
*       - function NewGroup takes nothing returns group
*       - function ReleaseGroup takes group g returns nothing
*           - Get and release group handles
*
*       - function GroupRefresh takes group g returns nothing
*           - Refresh a group so that null units are removed
*
*       - function GroupUnitsInArea takes group whichGroup, real x, real y, real radius returns nothing
*           - Groups units while taking into account collision
*
***************************************/
library GroupTools
   
    globals
        // The highest collision size you're using in your map.
        private constant real MAX_COLLISION_SIZE = 197.
        // Data Variables
        private group array groups
        private integer gN = 0
        // Global Group (Change it to CreateGroup() if you want)
        group ENUM_GROUP = bj_lastCreatedGroup
    endglobals
   
    static if DEBUG_MODE then
        private struct V extends array
            debug static hashtable ht = InitHashtable()
        endstruct
    endif
   
    function GroupRefresh takes group g returns nothing
        local group tempG = CreateGroup()
        
        debug if null==g then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[GroupUtils]Error: Attempt to refresh null group!")
            debug return
        debug endif
        
        call BlzGroupAddGroupFast(g, tempG)
        call GroupClear(g)
        call BlzGroupAddGroupFast(tempG, g)
        call DestroyGroup(tempG)
        set g = null
    endfunction
   
    function NewGroup takes nothing returns group
        if 0==gN then
            return CreateGroup()
        endif
        set gN = gN - 1
        debug call SaveBoolean(V.ht,GetHandleId(groups[gN]),0,false)
        return groups[gN]
    endfunction
   
    function ReleaseGroup takes group g returns nothing
        debug if null==g then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[GroupUtils]Error: Attempt to release null group!")
            debug return
        debug endif
        debug if LoadBoolean(V.ht,GetHandleId(g),0) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[GroupUtils]Error: Double free!")
            debug return
        debug endif
        debug call SaveBoolean(V.ht,GetHandleId(g),0,true)
        call GroupClear(g)
        set groups[gN] = g
        set gN = gN + 1
    endfunction
   
    function GroupUnitsInArea takes group whichGroup, real x, real y, real radius returns nothing
        local unit u
        debug if null==whichGroup then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[GroupUtils]Error: Null group passed to GroupUnitsInArea!")
            debug return
        debug endif
        call GroupEnumUnitsInRange(ENUM_GROUP,x,y,radius+MAX_COLLISION_SIZE,null)
        loop
            set u = FirstOfGroup(ENUM_GROUP)
            exitwhen null==u
            if IsUnitInRangeXY(u,x,y,radius) then
                call GroupAddUnit(whichGroup,u)
            endif
            call GroupRemoveUnit(ENUM_GROUP,u)
        endloop
    endfunction
   
endlibrary
