/*
This trigger will periodically remove all dead items from the game, so they don't leak.

It has been determined, by testing, that you must revive an item (increase it's life) before removing it from the game, or it will still be in the game and leak.

Thanks to Hive Workshop usesr: 
-"Tirlititi" => Found out that you need to set dead item life to 1 before removing
-"Bribe" => Giving timer idea so death animation could be played (didn't use his GUI system because it would add too many variables)

Script by Guhun
*/
scope LoPItemCleanup initializer onInit  // Uses ArrayAgent

// The timer will remove dead items from the game every few seconds. Set the value below to determine that period.
private constant function CleaningPeriod takes nothing returns real
    return 15.00  
endfunction

private function DestroyDeadItems takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tKey = GetAgentKey(t)
    local integer aKey = GetAgentKey(AgentLoadTrigger(tKey, 0))
    local item my_Item
    local integer size = AgentLoadInteger(aKey, 0)
    local integer i = 1
    
    loop
    exitwhen i > size
        set my_Item = AgentLoadItem(aKey, i)
        call SetWidgetLife(my_Item, 1)
        call RemoveItem(my_Item)
        set i = i+1
    endloop
    
    call AgentFlush(tKey)
    call AgentFlush(aKey)
    call PauseTimer(t)
    call DestroyTimer(t)
    
    set t = null
    set my_Item = null
endfunction

private function ForItem takes nothing returns nothing
    local integer aKey
    local integer size
    if GetWidgetLife(GetEnumItem()) == 0 then
        set aKey = GetAgentKey(GetTriggeringTrigger())
        set size = AgentLoadInteger(aKey, 0)
        call AgentSaveAgent(aKey, size , GetEnumItem() )
        call AgentSaveInteger(aKey, 0, size+1)
    endif
endfunction

private function TrigActions takes nothing returns nothing
    local timer t
    local integer aKey = CreateAgentKey(GetTriggeringTrigger())
    
    call AgentSaveInteger(aKey, 0, 1)
    call EnumItemsInRect( udg_WholeMapRegion, null, function ForItem )
    
    if AgentLoadInteger(aKey, 0) > 1 then
        set t = CreateTimer()
        call TimerStart(t, 1.5 , false , function DestroyDeadItems)
        call AgentSaveAgent(CreateAgentKey(t), 0, GetTriggeringTrigger())
        set t = null
    else
        call AgentFlush(aKey)
    endif
endfunction

private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    call TriggerRegisterTimerEvent(trig, CleaningPeriod(), true )
    call TriggerAddAction( trig, function TrigActions )
endfunction

endscope


