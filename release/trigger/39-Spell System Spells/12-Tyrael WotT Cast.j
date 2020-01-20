scope WillOfTheTribunal

private struct CasterData extends array

    //! runtextmacro TableStruct_NewAgentField("timer","timer")

    method destroy takes nothing returns nothing
        call timerClear()
    endmethod
endstruct

//===========================================================================
// CONFIG (some of it is in the Object Editor ability)
//===========================================================================
private constant function ATTACK_SPEED_REDUCTION takes nothing returns integer
    return -20
endfunction

private constant function MOVE_SPEED_REDUCTION takes nothing returns real
    return 0.5
endfunction

private constant function BASE_ORDER_ID takes nothing returns string
    return "entangle"
endfunction

//===========================================================================
// CODE
//===========================================================================
// Spell end and cleanup
private function GroupRemoveDebuff takes nothing returns nothing
    local unit u = GetEnumUnit()
    call CSS_AddBonus(u, -ATTACK_SPEED_REDUCTION(), 1)
    call UnitMultiplyMoveSpeed(u, 1./MOVE_SPEED_REDUCTION())
    set u = null
endfunction

//===========================================================================
// Spell Main Loop
private function WotTTimerAction takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tKey = GetAgentKey(GetExpiredTimer())
    local integer circleId = AgentLoadInteger(tKey, 0)
    local unit dummy = AgentLoadUnit(tKey, 1)
    local CasterData casterData = AgentLoadInteger(tKey, 3)
    local group slowGroup
    
    local integer i = 0
    

    if OrderId2String(GetUnitCurrentOrder(AgentLoadUnit(tKey, 2))) == BASE_ORDER_ID() and t == casterData.timer then
        call UpdateGCOS(circleId)
        loop
        exitwhen i > 8
            call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circleId,i), GetGCOSPointY(circleId,i))
            set i = i + 1
        endloop
    else
        if t == casterData.timer then
            debug call BJDebugMsg("Deleting WotT timer.")
            call casterData.destroy()
        debug else
            debug call BJDebugMsg("Deleting WotT replaced timer.")
        endif
        
        set slowGroup = AgentLoadGroup(tKey, 4)
        call ForGroup(slowGroup, function GroupRemoveDebuff)
    
        call DestroyGroup(slowGroup)
        call DestroyGCOS(circleId)
        call DummyDmg_RemoveDummy(dummy)
        call AgentFlush(tKey)
        call AgentFlush(GetAgentKey(dummy))
        call PauseTimer(t)
        call DestroyTimer(t)
    endif
    
    set dummy = null
    set t = null
    set slowGroup = null
endfunction

//===========================================================================
// Spell Cast Event Response
private function onCast takes nothing returns nothing
    local integer circleId = CreateGCOS(0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 200, 200, 16, 0, bj_PI/4)
    local timer t = CreateTimer()
    local integer tKey = CreateAgentKey(t)
    local group slowGroup = CreateGroup()
    local unit dummy = DummyDmg_CreateDummyAt(udg_Spell__Caster, 'A04B', GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), -1.)
    
    call DummyDmg_AddAbility(dummy,'A045')
    
    call AgentSaveInteger(tKey, 0, circleId)
    call AgentSaveAgent(tKey,   1, dummy)
    call AgentSaveAgent(tKey,   2, udg_Spell__Caster)
    call AgentSaveInteger(tKey, 3, GetHandleId(udg_Spell__Caster))  // Save HandleId so CasterData can be cleared even if caster is deleted.
    call AgentSaveAgent(tKey,   4, slowGroup)  // Save group in timer so it can be destroyed even if the dummy is deleted.
    call AgentSaveAgent(CreateAgentKey(dummy),   0, slowGroup)
    
    set CasterData(GetHandleId(udg_Spell__Caster)).timer = t
    
    debug call BJDebugMsg("Sucessfully Cast Will of the Tribunal")
    
    call TimerStart(t,1,true, function WotTTimerAction)
    set t = null
    set slowGroup = null
    set dummy = null
endfunction

//===========================================================================
// Dummy on damage trigger
private function onDamage takes nothing returns boolean
    local group slowGroup = AgentLoadGroup(GetAgentKey(udg_DamageEventSource), 0)
    if not IsUnitInGroup(udg_DamageEventTarget, slowGroup) then
        call CSS_AddBonus(udg_DamageEventTarget, ATTACK_SPEED_REDUCTION(), 1)
        call UnitMultiplyMoveSpeed(udg_DamageEventTarget, MOVE_SPEED_REDUCTION())
        call GroupAddUnit(slowGroup, udg_DamageEventTarget)
        
        debug call BJDebugMsg("Debug Message: "+GetUnitName(udg_DamageEventTarget)+" added to WotT group!")
    endif
    
    set slowGroup = null
    return false
endfunction


//===========================================================================
function InitTrig_Tyrael_WotT_Cast takes nothing returns nothing
    set gg_trg_Tyrael_WotT_Cast = CreateTrigger()
    call TriggerAddAction(gg_trg_Tyrael_WotT_Cast, function onCast)
    
    //Tyrael - Will of the Tribunal: Slow damaged Units 
    call InitializeOnDamageTrigger(CreateTrigger(), 'A04B', function onDamage)
    //-------------------------------------------------
endfunction

endscope
