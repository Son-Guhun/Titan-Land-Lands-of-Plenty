library TimedBonus requires MoveSpeedBonus

// TODO: Change implementation to use a Linked Hash Set instead of an array to pass parameters.

function TimedBonusTimerFunc takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetAgentKey(t)
    local unit timerUnit = AgentLoadUnit(tId, -1)
    local integer bonusType = 0

    loop
    exitwhen bonusType>10
        if -AgentLoadInteger(tId, bonusType) != 0. then
            call CSS_AddBonus(timerUnit, -AgentLoadInteger(tId, bonusType) , bonusType)
        endif
        set bonusType = bonusType + 1
    endloop
    
    if AgentHaveSavedReal(tId, bonusType) then
        call GMSS_UnitAddMoveSpeed(timerUnit, -AgentLoadReal(tId, bonusType))
    endif
    if AgentHaveSavedReal(tId, bonusType+1) then
        call GMSS_UnitMultiplyMoveSpeed(timerUnit, 1./AgentLoadReal(tId, bonusType + 1))
    endif
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call AgentFlush(tId)

    set t = null
    set timerUnit = null
endfunction

function AddTimedBonus takes unit whichUnit, real moveAdd, real moveMul, real duration returns nothing
    local integer bonusType = 0
    local timer t = CreateTimer()
    local integer tId = CreateAgentKey(t)

    loop
    exitwhen bonusType>10
        if udg_TimerBonuses[bonusType] != 0 then
            call CSS_AddBonus(whichUnit, udg_TimerBonuses[bonusType] , bonusType)
            call AgentSaveInteger(tId, bonusType, udg_TimerBonuses[bonusType])
            set udg_TimerBonuses[bonusType] = 0
        endif
        set bonusType = bonusType + 1
    endloop

    if moveAdd != 0 then
        call AgentSaveReal(tId, bonusType, moveAdd)
        call GMSS_UnitAddMoveSpeed(whichUnit, moveAdd)
    endif
    if moveMul > 0 and moveMul != 1 then
        call AgentSaveReal(tId, bonusType + 1, moveMul)
        call GMSS_UnitMultiplyMoveSpeed(whichUnit, moveMul)
    endif

    call AgentSaveAgent(tId, -1, whichUnit)
    call TimerStart(t, duration, false, function TimedBonusTimerFunc)
    
    set t = null
endfunction

endlibrary
