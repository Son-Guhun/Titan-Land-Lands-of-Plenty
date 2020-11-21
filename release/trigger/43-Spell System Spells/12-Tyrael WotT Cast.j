scope WillOfTheTribunal

private struct CasterData extends array

    //! runtextmacro TableStruct_NewAgentField("timer","timer")

    method destroy takes nothing returns nothing
        call timerClear()
    endmethod
endstruct

private struct TimerData extends array

    implement AgentStruct

    //! runtextmacro HashStruct_NewAgentField("dummy", "unit")
    //! runtextmacro HashStruct_NewAgentField("caster", "unit")
    //! runtextmacro HashStruct_NewPrimitiveField("circleId", "integer")
    //! runtextmacro HashStruct_NewStructField("casterData", "CasterData")
    //! runtextmacro HashStruct_NewAgentField("slowGroup", "group")
endstruct

private struct DummyData extends array

    implement AgentStruct
    
    //! runtextmacro HashStruct_NewAgentField("slowGroup", "group")
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
    local TimerData tKey = TimerData.get(GetExpiredTimer())
    local integer circleId = tKey.circleId
    local unit dummy = tKey.dummy
    local CasterData casterData = tKey.casterData
    local group slowGroup
    
    local integer i = 0
    

    if OrderId2String(GetUnitCurrentOrder(tKey.caster)) == BASE_ORDER_ID() and t == casterData.timer then
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
        
        set slowGroup = tKey.slowGroup
        call ForGroup(slowGroup, function GroupRemoveDebuff)
    
        call DestroyGroup(slowGroup)
        call DestroyGCOS(circleId)
        call DummyDmg_RemoveDummy(dummy)
        call tKey.destroy()
        call DummyData.get(dummy).destroy()
        call PauseTimer(t)
        call DestroyTimer(t)
    endif
    
    set dummy = null
    set t = null
    set slowGroup = null
endfunction

//===========================================================================
// Spell Cast Event Response
private function onEffect takes nothing returns nothing
    local integer circleId = CreateGCOS(0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 200, 200, 16, 0, bj_PI/4)
    local timer t = CreateTimer()
    local TimerData tKey = TimerData.get(t)
    local group slowGroup = CreateGroup()
    local unit dummy = DummyDmg_CreateDummyAt(udg_Spell__Caster, 'A04B', GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), -1.)
    
    call DummyDmg_AddAbility(dummy,'A045')
    
    set tKey.circleId = circleId
    set tKey.dummy = dummy
    set tKey.caster = udg_Spell__Caster
    set tKey.casterData = GetHandleId(udg_Spell__Caster)  // Save HandleId so CasterData can be cleared even if caster is deleted.
    set tKey.slowGroup = slowGroup  // Save group in timer so it can be destroyed even if the dummy is deleted.
    set DummyData.get(dummy).slowGroup = slowGroup
    
    set CasterData(GetHandleId(udg_Spell__Caster)).timer = t
    
    call TimerStart(t,1,true, function WotTTimerAction)
    set t = null
    set slowGroup = null
    set dummy = null
endfunction

//===========================================================================
// Dummy on damage trigger
private function onDamage takes nothing returns boolean
    local group slowGroup = DummyData.get(udg_DamageEventSource).slowGroup
    
    if not IsUnitInGroup(udg_DamageEventTarget, slowGroup) then
        call CSS_AddBonus(udg_DamageEventTarget, ATTACK_SPEED_REDUCTION(), 1)
        call UnitMultiplyMoveSpeed(udg_DamageEventTarget, MOVE_SPEED_REDUCTION())
        call GroupAddUnit(slowGroup, udg_DamageEventTarget)
    endif
    
    set slowGroup = null
    return false
endfunction


//===========================================================================
function InitTrig_Tyrael_WotT_Cast takes nothing returns nothing
    call RegisterSpellSimple('A04B', function onEffect, null)
    call InitializeOnDamageTrigger(CreateTrigger(), 'A04B', function onDamage)
endfunction

endscope
