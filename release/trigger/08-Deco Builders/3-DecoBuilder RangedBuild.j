function InstaBuildTimer takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetHandleId(t)
    local unit u = LoadUnitHandle(udg_Hashtable_1, tId, 0)
    call IssueImmediateOrder(u, "stop")
    call PauseTimer(t)
    call DestroyTimer(t)
    call FlushChildHashtable(udg_Hashtable_1,tId)
    
    set t = null
    set u = null
endfunction

function Trig_Deco_RangedBuild_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local timer t = CreateTimer()
    local integer builtUnitType = GetIssuedOrderId()  // Only works for undead build ability!!!
    
    if not IsUnitIdType(builtUnitType, UNIT_TYPE_MECHANICAL) or (GetUnitAbilityLevel(u,'A0C7') != 0) or (GetUnitAbilityLevel(u,'A0C8') !=0 ) or (GetUnitAbilityLevel(u,'A0CA') ==0 ) then
        return
    endif
    
    call CreateUnit(GetOwningPlayer(u), builtUnitType, GetOrderPointX(), GetOrderPointY(), bj_UNIT_FACING)
    
    // Can't instantly order the builder to stop, must start a timer
    call TimerStart(t, 0,false, function InstaBuildTimer)
    call SaveUnitHandle(udg_Hashtable_1,GetHandleId(t), 0, u)
    

    set t = null
    set u = null
endfunction

//===========================================================================
function InitTrig_DecoBuilder_RangedBuild takes nothing returns nothing
    set gg_trg_DecoBuilder_RangedBuild = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_DecoBuilder_RangedBuild, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
    call TriggerAddAction( gg_trg_DecoBuilder_RangedBuild, function Trig_Deco_RangedBuild_Actions )
endfunction



    //set udg_System_ConstructingUnit = u
    //set udg_System_ConstructingUnitX = GetUnitX(u)
    //set udg_System_ConstructingUnitY = GetUnitY(u)
    //call SetUnitX(GetTriggerUnit(),GetOrderPointX())
    //call SetUnitY(GetTriggerUnit(),GetOrderPointY())
