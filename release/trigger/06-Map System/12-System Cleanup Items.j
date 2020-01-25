/*
This trigger will periodically remove all dead items from the game, so they don't leak.

It has been determined, by testing, that you must revive an item (increase it's life) before removing it from the game, or it will still be in the game and leak.

Thanks to Hive Workshop usesr: 
-"Tirlititi" => Found out that you need to set dead item life to 1 before removing
-"Bribe" => Giving timer idea so death animation could be played (didn't use his GUI system because it would add too many variables)

Script by Guhun
*/
scope LoPItemCleanup initializer onInit  // Uses ArrayAgent

private struct Globals extends array

    static key static_members_key
    //! runtextmacro TableStruct_NewStaticPrimitiveField("size","integer")
    //! runtextmacro TableStruct_NewStaticAgentField("timer","timer")
    //! runtextmacro TableStruct_NewConstTableField("public", "items")

endstruct

// The timer will remove dead items from the game every few seconds. Set the value below to determine that period.
private constant function CleaningPeriod takes nothing returns real
    return 15.00  
endfunction

private function DestroyDeadItems takes nothing returns nothing
    local item my_Item
    local integer size = Globals.size
    local integer i = 1
    
    loop
    exitwhen i > size
        set my_Item = Globals.items.item[i]
        call SetWidgetLife(my_Item, 1)
        call RemoveItem(my_Item)
        set i = i+1
    endloop
    
    set my_Item = null
endfunction

private function ForItem takes nothing returns nothing
    local integer size
    if GetWidgetLife(GetEnumItem()) == 0 then
        set size = Globals.size
        set Globals.items.item[size] = GetEnumItem()
        set Globals.size = size+1
    endif
endfunction

private function TrigActions takes nothing returns nothing
    set Globals.size = 0
    call EnumItemsInRect( udg_WholeMapRegion, null, function ForItem )
    
    if Globals.size > 0 then
        call TimerStart(Globals.timer, 1.5 , false , function DestroyDeadItems)
    endif
endfunction

private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    set Globals.timer = CreateTimer()
    call TriggerRegisterTimerEvent(trig, CleaningPeriod(), true )
    call TriggerAddAction( trig, function TrigActions )
endfunction

endscope


