scope SystemDeselect
/*
 This library functions by having an array of groups. Every second, the next group (cyclically) is
 iterated over and any units in that group are hidden. Therefore, to hide a unit after x seconds,
 simply add it to group number (current + x) % TOTAL_GROUPS, with x <= TOTAL_GROUPS.
*/

// How to use this text macro:
//  - Define a field (e.g: 'integer a' or 'TableStruct_NewPrimitiveField("a", "integer")')
//  - Run this macro below that field's declaration.
//  - You can now use the [] operator statically on the struct, using that field's type.
//! textmacro TableStruct_DefineStaticArray takes FIELD, TYPE
    static method operator[] takes integer i returns $TYPE$
        return thistype(i).$FIELD$
    endmethod
    
    static method operator[]= takes integer i, $TYPE$ g returns nothing
        set thistype(i).$FIELD$ = g
    endmethod
//! endtextmacro

private struct GroupArray extends array
    static key static_members_key
    
    static constant method operator TOTAL_GROUPS takes nothing returns integer
        return 5  // Maximum number of seconds is equal to number of groups
    endmethod

    //! runtextmacro TableStruct_NewStaticPrimitiveField("current", "integer")
    
    //! runtextmacro TableStruct_NewReadonlyHandleField("groups", "group")
    //! runtextmacro TableStruct_DefineStaticArray("groups", "group")

endstruct

private function onTimer takes nothing returns nothing
    local group g
    local unit u
    
    set GroupArray.current = ModuloInteger(GroupArray.current+1, GroupArray.TOTAL_GROUPS)
    set g = GroupArray[GroupArray.current]
    
    if BlzGroupGetSize(g) > 0 then
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if not IsUnitSelected(u, GetOwningPlayer(u)) and LoP_UnitData.get(u).hideOnDeselect then
                call ShowUnit(u, false)
            endif
        endloop
    endif

    set u = null
endfunction

function onDeselect takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    
    if GetOwningPlayer(trigU) == GetTriggerPlayer() and LoP_UnitData.get(trigU).hideOnDeselect then
        call GroupAddUnit(GroupArray[GroupArray.current], trigU)
    endif
    
    set trigU = null
    return false
endfunction

//===========================================================================
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

