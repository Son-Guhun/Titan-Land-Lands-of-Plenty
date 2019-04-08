scope MultiPatrolCommands initializer onInit

private function CommandActions takes nothing returns nothing
    local group selectedGrp = CreateGroup()
    local unit u

    call GroupEnumUnitsSelected(selectedGrp, GetTriggerPlayer(), null)
    
    if GetEventPlayerChatString() == "-patrol clear" then
        set u = FirstOfGroup(selectedGrp)
        loop
        exitwhen u == null
            call Patrol_ClearUnitData(u)
            call GroupRemoveUnit(selectedGrp, u)
            set u = FirstOfGroup(selectedGrp)
        endloop
    elseif GetEventPlayerChatString() == "-patrol resume" then
        set u = FirstOfGroup(selectedGrp)
        loop
        exitwhen u == null
            call Patrol_ResumePatrol(u)
            call GroupRemoveUnit(selectedGrp, u)
            set u = FirstOfGroup(selectedGrp)
        endloop
    endif
    
    call DestroyGroup(selectedGrp)
    set selectedGrp = null
    set u = null
endfunction

private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger(  )
    local integer i = 0
    call TriggerAddAction( trig, function CommandActions )
    
    loop
    exitwhen i >= bj_MAX_PLAYERS
        if IsPlayerInForce(Player(i), bj_FORCE_ALL_PLAYERS) then 
            call TriggerRegisterPlayerChatEvent(trig, Player(i), "-patrol ", false)
        endif
        set i = i + 1
    endloop
endfunction

endscope

scope MultiPatrolOrder initializer onInit

private function IsUnitOnlySelected takes unit trigU returns boolean
    local group selectedGrp = CreateGroup()
    local unit firstOfGrp
    local integer groupCounter = 0 
    
    local boolean trigUnitInSelection = false
    
    call GroupEnumUnitsSelected(selectedGrp, GetOwningPlayer(trigU), null)
    set firstOfGrp = FirstOfGroup(selectedGrp)
    loop
    exitwhen groupCounter > 1 or firstOfGrp == null
        set groupCounter = groupCounter + 1
        call GroupRemoveUnit(selectedGrp,firstOfGrp)
        if firstOfGrp == trigU then
            set trigUnitInSelection = true
        endif
        set firstOfGrp = FirstOfGroup(selectedGrp)
    endloop
    
    call DestroyGroup(selectedGrp)
    set selectedGrp = null
    set firstOfGrp = null
    
    return groupCounter == 1 and trigUnitInSelection
endfunction

private function OnPatrolOrderCondition takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    
    if Patrol_IsValidPatrolOrder(GetIssuedOrderId()) and IsUnitOnlySelected(trigU) then
        call Patrol_RegisterPoint(trigU, GetOrderPointX(), GetOrderPointY())
    endif
    
    set trigU = null
    
    return false
endfunction

private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
    call TriggerAddCondition( trig, Condition( function OnPatrolOrderCondition ) )
endfunction

endscope

/*
scope MultiPatrolDisplayOnSelect initializer onInit

globals
    // The time between each player's selection being enumerated.
    private constant real PERIOD = 0.25

    private group stack_grp = CreateGroup()
endglobals

private function onSelect takes nothing returns nothing
    local unit u
    local integer i = 0
    local group selectedGrp = CreateGroup()
    
    loop
    exitwhen i >= bj_MAX_PLAYERS
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            call GroupEnumUnitsSelected(selectedGrp, Player(i), null)
        endif
        set i = i+1
    endloop
    
    set u = FirstOfGroup(stack_grp)
    loop
        exitwhen u == null
            if not IsUnitInGroup(u, selectedGrp) then
                call Patrol_DestroyPoints(u)
            endif
            call GroupRemoveUnit(stack_grp, u)
            set u = FirstOfGroup(stack_grp)
    endloop
    
    set u = FirstOfGroup(selectedGrp)
    loop
        exitwhen u == null
            call Patrol_DisplayPoints(u)
            call GroupRemoveUnit(selectedGrp, u)
            call GroupAddUnit(stack_grp, u)
            set u = FirstOfGroup(selectedGrp)
    endloop
    
    call DestroyGroup(selectedGrp)
    set selectedGrp = null
endfunction

//===========================================================================
private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger(  )
    call TriggerRegisterTimerEvent( trig, PERIOD, true)
    call TriggerAddAction( trig, function onSelect )
endfunction

endscope
*/