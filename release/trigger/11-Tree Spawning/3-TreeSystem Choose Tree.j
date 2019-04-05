function TreeIssueStopOrder takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetHandleId(t)
    local unit deco = LoadUnitHandle(udg_Hashtable_1, tId , 'tree')
    
    call IssueImmediateOrder(deco, "stop")
    
    call PauseTimer(t)
    call DestroyTimer(t)
    
    call FlushChildHashtable(udg_Hashtable_1, tId)
    
    set t = null
    set deco= null

endfunction

function Trig_TreeSystem_Choose_Tree_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'u015' ) ) then
        return false
    endif
    if not (OrderId2String(GetIssuedOrderId()) == "smart") then
        return false
    endif
    return true
endfunction

function Trig_TreeSystem_Choose_Tree_Actions takes nothing returns nothing
    local timer t
    
    if GetOrderTargetDestructable() == null then

        return
    endif
    
    //call BJDebugMsg(GetDestructableName(GetOrderTargetDestructable()))
    
    set t = CreateTimer()
    set udg_TreeSystem_TREES[GetConvertedPlayerId(GetOwningPlayer(GetTriggerUnit()))] = GetDestructableTypeId(GetOrderTargetDestructable())
    call TimerStart(t, 0, false, function TreeIssueStopOrder)
    call SaveUnitHandle(udg_Hashtable_1, GetHandleId(t) , 'tree', GetTriggerUnit())
    set t = null
endfunction

//===========================================================================
function InitTrig_TreeSystem_Choose_Tree takes nothing returns nothing
    set gg_trg_TreeSystem_Choose_Tree = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_TreeSystem_Choose_Tree, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER )
    call TriggerAddCondition( gg_trg_TreeSystem_Choose_Tree, Condition( function Trig_TreeSystem_Choose_Tree_Conditions ) )
    call TriggerAddAction( gg_trg_TreeSystem_Choose_Tree, function Trig_TreeSystem_Choose_Tree_Actions )
endfunction

