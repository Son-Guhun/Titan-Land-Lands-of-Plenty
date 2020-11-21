scope SystemDeselect
/*
=========
 Description
=========

    This code hides units which have been deselected, after 5 seconds. It will not hide the unit if
it was reselected during that time and is still selected at the moment.

    Only units which were tagged for hiding will be hidden. See the hideOnDeselect field of LoP_UnitData
in LoPWidgets.

*/

// ================================================================
//  Source Code
// ================================================================
/*
    This library functions by having a static array of groups. They are created at map initialization
and are never destroyed.
*/ 

private struct GroupArray extends array
    static key static_members_key
    
    //! runtextmacro TableStruct_NewReadonlyHandleField("groups", "group")
    //! runtextmacro TableStruct_DefineStaticArray("groups", "group")
    
    static constant method operator TOTAL_GROUPS takes nothing returns integer
        return 5  // The maximum delay (in seconds) is equal to number of groups created.
    endmethod

    // Returns the index of the group which was most recently processed.
    //! runtextmacro TableStruct_NewStaticPrimitiveField("current", "integer")
    
    // Returns the index of the group which will be processed after the given number of cycles.
    // Each cycle is separated by 1 second.
    static method queuePos takes integer seconds returns integer
        return ModuloInteger(current + seconds, TOTAL_GROUPS)
    endmethod
    
    // Returns the index of the group which will be processed in the next cycle.
    static method next takes nothing returns integer
        return queuePos(1)
    endmethod

endstruct

/*
    Every second, the next group (cyclically) is iterated over and any units in that group are hidden.
*/
private function onTimer takes nothing returns nothing
    local group g
    local unit u
    
    set GroupArray.current = GroupArray.next()
    set g = GroupArray[GroupArray.current]
    
    if BlzGroupGetSize(g) > 0 then
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if not IsUnitSelected(u, GetOwningPlayer(u)) and LoP_UnitData.get(u).hideOnDeselect then
                call ShowUnit(u, false)
            endif
        endloop
        // No need to clear the group, as ForUnitInGroup uses a FirstOfGroup loop.
    endif

    set u = null
endfunction

/*
    To hide a unit after x seconds, simply add it the xTh group in the queue, with x <= TOTAL_GROUPS.

    If x is the maximum number of seconds supported, then you simply need to add it to the current group.
*/

private function HideUnitDelayed takes integer delay, unit whichUnit returns nothing
    call GroupAddUnit(GroupArray[GroupArray.queuePos(delay)], whichUnit)
endfunction

private function HideUnitMaxDelay takes unit whichUnit returns nothing
    call GroupAddUnit(GroupArray[GroupArray.current], whichUnit)
endfunction

//===========================================================================


private function onDeselect takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    
    if GetOwningPlayer(trigU) == GetTriggerPlayer() and LoP_UnitData.get(trigU).hideOnDeselect then
        call HideUnitMaxDelay(trigU)
    endif
    
    set trigU = null
    return false
endfunction


function InitTrig_System_Deselect takes nothing returns nothing
    local integer i = GroupArray.TOTAL_GROUPS
    
    set gg_trg_System_Deselect = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_System_Deselect, Condition(function onDeselect))
    
    set GroupArray.current = 0
    call TimerStart(CreateTimer(), 1., true, function onTimer)
    loop
        set i = i - 1
        set GroupArray[i] = CreateGroup()
        exitwhen i <= 0
    endloop
endfunction

endscope

