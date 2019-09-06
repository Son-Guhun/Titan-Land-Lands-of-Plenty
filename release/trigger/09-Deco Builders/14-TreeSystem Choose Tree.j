scope TreeSystemChooseTree

private struct Globals extends array
    //! runtextmacro TableStruct_NewConstTableField("","timerData")
endstruct

function TreeIssueStopOrder takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetHandleId(t)
    local unit deco = Globals.timerData.unit[GetHandleId(t)]
    
    call IssueImmediateOrder(deco, "stop")
    
    call PauseTimer(t)
    call DestroyTimer(t)
    
    call Globals.timerData.unit.remove(tId)
    
    set t = null
    set deco= null

endfunction

function Trig_TreeSystem_Choose_Tree_Conditions takes nothing returns boolean
    local timer t

    if GetUnitTypeId(GetTriggerUnit()) == 'u015' and OrderId2String(GetIssuedOrderId()) == "smart" then
        
        if GetOrderTargetDestructable() != null then
            set t = CreateTimer()
            set udg_TreeSystem_TREES[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))+1] = GetDestructableTypeId(GetOrderTargetDestructable())
            call TimerStart(t, 0, false, function TreeIssueStopOrder)
            set Globals.timerData.unit[GetHandleId(t)] = GetTriggerUnit()
            set t = null
        endif
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_TreeSystem_Choose_Tree takes nothing returns nothing
    set gg_trg_TreeSystem_Choose_Tree = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_TreeSystem_Choose_Tree, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER )
    call TriggerAddCondition( gg_trg_TreeSystem_Choose_Tree, Condition( function Trig_TreeSystem_Choose_Tree_Conditions ) )
endfunction

endscope

