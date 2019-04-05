library TimedBonus requires MoveSpeedBonus

// TODO: Change implementation to use a Linked Hash Set instead of an array to pass parameters.

globals
    constant integer CSS_ARMOR = 0
    constant integer CSS_ATKSPEED = 1
    constant integer CSS_DAMAGE = 2
    constant integer CSS_AGI = 3
    constant integer CSS_INT = 4
    constant integer CSS_STR = 5
    constant integer CSS_LIFE_REGEN = 6
    constant integer CSS_MANA_REGEN = 7
    constant integer CSS_LIFE = 8
    constant integer CSS_MANA = 9
    constant integer CSS_SIGHT_RANGE = 10
endglobals

function TimedBonusTimerFunc takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetAgentKey(t)
    local unit timerUnit = AgentLoadUnit(tId, -1)
    local integer bonusType = 0

    loop
    exitwhen bonusType>10
        call CSS_AddBonus(timerUnit, -AgentLoadInteger(tId, bonusType) , bonusType)
        set bonusType = bonusType + 1
    endloop
    
    call GMSS_UnitAddMoveSpeed(timerUnit, -AgentLoadReal(tId, bonusType))
    call GMSS_UnitMultiplyMoveSpeed(timerUnit, 1./AgentLoadReal(tId, bonusType + 1))
    
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
