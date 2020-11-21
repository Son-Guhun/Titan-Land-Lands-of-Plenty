//===========================================================================
// Description
//====================

// This code is supposed to preclude units without a Ruby Key and who are not owned by the Titan
// from buying items from a shop inside of the Inner Titan Palace.

// This system assumes that the shops in the Titan Palace are owned by Neutral Passive.

//===========================================================================
// Configuration
//====================

// This is the Rect (GUI Region) which is protected by this trigger.
constant function System_ProtectedRect takes nothing returns rect
    return gg_rct_Titan_Palace_Inner
endfunction

// This is the rawcode of the item which allows units to bypass the protection and buy items.
constant function System_RUBY_KEY takes nothing returns integer
    return 'I008'
endfunction

//===========================================================================
// Code
//====================
// The protection system is NOT supposed to be fired off very often. So, in order to optimize the
// code execution during the map, we will separate the condition from the action and optimize the
// conditions as much as possible.

// titanPalaceInner is defined in System Titan Palace Prot.

scope TitanPalaceItemProtect


function Trig_System_Titan_Palace_Item_Prot_Conditions takes nothing returns boolean
    return IsUnitInRegion(titanPalaceInner, GetBuyingUnit()) and not (GetOwningPlayer(GetBuyingUnit()) == udg_GAME_MASTER or /*
                                                                */ UnitHasItemOfTypeBJ(GetBuyingUnit(), System_RUBY_KEY()))
endfunction

private struct TimerData extends array
    
    implement AgentStruct
    
    //! runtextmacro HashStruct_NewAgentField("unit","unit")
    //! runtextmacro HashStruct_NewAgentField("item","item")
    
endstruct

function System_TPalaceProtection_Timer takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local TimerData tId = TimerData.get(t)
    local unit u = tId.unit
    local item i = tId.item
    
    call UnitRemoveItem(u, i)
    call RemoveItem(i)
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call tId.destroy()
    
    set t = null
    set u = null
    set i = null
endfunction

function Trig_System_Titan_Palace_Item_Prot_Actions takes nothing returns nothing
    local timer t
    local TimerData tId
    local item i = GetSoldItem()

    if IsItemPowerup(i) then
        call RemoveItem( i )
    else
        set t = CreateTimer()
        call TimerStart(t, 0, false, function System_TPalaceProtection_Timer)
        set tId = TimerData.get(t)
        set tId.unit = GetBuyingUnit()
        set tId.item = i
        
        set t = null
    endif
    
    call DisplayTextToPlayer( GetOwningPlayer(GetBuyingUnit()), 0., 0., "You cannot buy items while the Titan Palace is protected!" )
    set i = null
endfunction

//===========================================================================
function InitTrig_System_Titan_Palace_Item_Prot takes nothing returns nothing
    set gg_trg_System_Titan_Palace_Item_Prot = CreateTrigger(  )
    call TriggerRegisterPlayerUnitEvent(gg_trg_System_Titan_Palace_Item_Prot, LoP.NEUTRAL_PASSIVE, EVENT_PLAYER_UNIT_SELL_ITEM, null)
    call TriggerAddCondition(gg_trg_System_Titan_Palace_Item_Prot, Condition( function Trig_System_Titan_Palace_Item_Prot_Conditions))
    call TriggerAddAction(gg_trg_System_Titan_Palace_Item_Prot, function Trig_System_Titan_Palace_Item_Prot_Actions)
endfunction


endscope
