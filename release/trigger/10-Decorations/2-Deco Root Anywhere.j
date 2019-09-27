scope DecoRootAnywhere

//! runtextmacro DefineHooks()

function Trig_Deco_Root_Anywhere_Conditions takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    
    if LoP_IsUnitDecoration(trigU) and GetIssuedOrderId() == OrderId("root") then
        call SetUnitX(trigU, GetOrderPointX())
        call SetUnitY(trigU, GetOrderPointY())
    endif
    
    set trigU = null
    return false
endfunction

//===========================================================================
function InitTrig_Deco_Root_Anywhere takes nothing returns nothing
    set gg_trg_Deco_Root_Anywhere = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Deco_Root_Anywhere, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    call TriggerAddCondition(gg_trg_Deco_Root_Anywhere, Condition(function Trig_Deco_Root_Anywhere_Conditions))
endfunction

endscope
