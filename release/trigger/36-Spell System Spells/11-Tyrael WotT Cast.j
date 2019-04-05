//===========================================================================
// CONFIG (some of it is in the Object Editor ability)
//===========================================================================
function WotT_ATTACK_SPEED_REDUCTION takes nothing returns integer
    return -20
endfunction

function WotT_MOVE_SPEED_REDUCTION takes nothing returns real
    return 0.5
endfunction

function WotT_BASE_ORDER_ID takes nothing returns string
    return "corporealform"
endfunction

//===========================================================================
// CODE
//===========================================================================
// Spell end and cleanup
function WotTSlowGroupRemoveDebuff takes nothing returns nothing
    local unit u = GetEnumUnit()
    call CSS_AddBonus(u, -WotT_ATTACK_SPEED_REDUCTION(), 1)
    call UnitMultiplyMoveSpeed(u, 1./WotT_MOVE_SPEED_REDUCTION())
    set u = null
endfunction

function WotTFinish takes timer t, integer tKey, unit dummy, integer circleId returns nothing
    local group slowGroup = AgentLoadGroup(GetAgentKey(dummy), 0)
    call ForGroup(slowGroup, function WotTSlowGroupRemoveDebuff)
    
    call DestroyGroup(slowGroup)
    call DestroyGCOS(circleId)
    call RemoveUnit(dummy)
    call AgentFlush(tKey)
    call AgentFlush(GetAgentKey(dummy))
    call PauseTimer(t)
    call DestroyTimer(t)

    set slowGroup = null
endfunction

//===========================================================================
// Spell Main Loop
function WotTTimerAction takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tKey = GetAgentKey(GetExpiredTimer())
    local integer circleId = AgentLoadInteger(tKey, 0)
    local unit dummy = AgentLoadUnit(tKey, 1)
    local integer i = 0

    if OrderId2String(GetUnitCurrentOrder(AgentLoadUnit(tKey, 2))) == WotT_BASE_ORDER_ID() then
        call UpdateGCOS(circleId)
        loop
        exitwhen i > 8
            call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circleId,i), GetGCOSPointY(circleId,i))
            set i = i + 1
        endloop
    else
        call WotTFinish(GetExpiredTimer(), tKey, dummy, circleId)
    endif
    
    set dummy = null
    set t = null
endfunction

//===========================================================================
// Spell Cast Event Response
function WotTCastAction takes nothing returns nothing
    local integer circleId = CreateGCOS(0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 200, 200, 16, 0, bj_PI/4)
    local timer t = CreateTimer()
    local integer tKey = CreateAgentKey(t)
    local group slowGroup = CreateGroup()
    local unit dummy = CreateUnit(udg_Spell__CasterOwner, 'h07Q', GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 270)//GetRecycledDummy(GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 0, 270)

    call UnitAddAbility(dummy,'A045')
    call AgentSaveInteger(tKey, 0, circleId)
    call AgentSaveAgent(tKey,   1, dummy)
    call AgentSaveAgent(tKey,   2, udg_Spell__Caster)
    call AgentSaveAgent(CreateAgentKey(dummy),   0, slowGroup)
    call DummyDmg_SetAbility(DummyDmg_GetKey(dummy),  'A04B')
    call DummyDmg_SetCaster(DummyDmg_GetKey(dummy),  udg_Spell__Caster)
    
    call TimerStart(t,1,true, function WotTTimerAction)
    set t = null
    set slowGroup = null
    set dummy = null
endfunction

//===========================================================================
// Dummy on damage trigger
function HoJSlowAction takes nothing returns boolean
    local group slowGroup = AgentLoadGroup(GetAgentKey(udg_DamageEventSource), 0)
    if not IsUnitInGroup(udg_DamageEventTarget, slowGroup) then
        call CSS_AddBonus(udg_DamageEventTarget, WotT_ATTACK_SPEED_REDUCTION(), 1)
        call UnitMultiplyMoveSpeed(udg_DamageEventTarget, WotT_MOVE_SPEED_REDUCTION())
        call GroupAddUnit(slowGroup, udg_DamageEventTarget)
        
        debug call BJDebugMsg("Debug Message: "+GetUnitName(udg_DamageEventTarget)+" added to WotT group!")
    endif
    
    set slowGroup = null
    return false
endfunction

//===========================================================================
function InitTrig_Tyrael_WotT_Cast takes nothing returns nothing
    set gg_trg_Tyrael_WotT_Cast = CreateTrigger()
    call TriggerAddAction(gg_trg_Tyrael_WotT_Cast, function WotTCastAction)
    
    //Tyrael - Will of the Tribunal: Slow damaged Units 
    call InitializeOnDamageTrigger(CreateTrigger(), 'A04B', function HoJSlowAction)
    //-------------------------------------------------
endfunction

