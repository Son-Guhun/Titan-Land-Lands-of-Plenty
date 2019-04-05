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

// This code is supposed to impede units without a Ruby Key and who are not owned by the Titan
// to buy items from a shop inside of the protected rect.

// This system assumes that the shops in the Titan Palace are owned by Neutral Passive.

// The protection system is NOT supposed to be fired off very often. So, in order to optimize the
// code execution during the map, we will separate the condition from the action and optimize the
// conditions as much as possible.
function Trig_System_Titan_Palace_Item_Prot_Conditions takes nothing returns boolean
    local real x = GetUnitX(GetTriggerUnit())
    local real y = GetUnitY(GetTriggerUnit())

    // Since the Titan Palace is on the top-left of the map, these conditions are more likely true
    if (x >= GetRectMaxX(System_ProtectedRect())) then
        return false
    endif
    if (y <= GetRectMinY(System_ProtectedRect())) then
        return false
    endif
    // ------
    if (x <= GetRectMinX(System_ProtectedRect())) then
        return false
    endif

    if (y >= GetRectMaxY(System_ProtectedRect())) then
        return false
    endif
    // ------
    
    if GetOwningPlayer(GetBuyingUnit()) == udg_GAME_MASTER  then
        return false
    endif
    
    if UnitHasItemOfTypeBJ(GetBuyingUnit(), System_RUBY_KEY()) then
        return false
    endif
    
    return true
endfunction

function System_TPalaceProtection_Timer takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetAgentKey(t)
    local unit u = AgentLoadUnit(tId, 0)
    local item i = AgentLoadItem(tId, 1)
    
    call UnitRemoveItem(u, i)
    call RemoveItem(i)
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call AgentFlush(tId)
    
    set t = null
    set u = null
    set i = null
endfunction

function Trig_System_Titan_Palace_Item_Prot_Actions takes nothing returns nothing
    local timer t
    local integer tId
    local item i = GetSoldItem()

    if IsItemPowerup(i) then
        call RemoveItem( i )
    else
        set t = CreateTimer()
        call TimerStart(t, 0, false, function System_TPalaceProtection_Timer)
        set tId = CreateAgentKey(t)
        call AgentSaveAgent(tId, 0, GetBuyingUnit())
        call AgentSaveAgent(tId, 1, i)
        
        set t = null
    endif
    
    call DisplayTextToPlayer( GetOwningPlayer(GetBuyingUnit()), 0., 0., "You cannot buy items while the Titan Palace is protected!" )
    set i = null
endfunction

//===========================================================================
function InitTrig_System_Titan_Palace_Item_Prot takes nothing returns nothing
    set gg_trg_System_Titan_Palace_Item_Prot = CreateTrigger(  )
    call TriggerRegisterPlayerUnitEvent(gg_trg_System_Titan_Palace_Item_Prot, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL_ITEM, null)
    call TriggerAddCondition(gg_trg_System_Titan_Palace_Item_Prot, Condition( function Trig_System_Titan_Palace_Item_Prot_Conditions))
    call TriggerAddAction(gg_trg_System_Titan_Palace_Item_Prot, function Trig_System_Titan_Palace_Item_Prot_Actions)
endfunction

