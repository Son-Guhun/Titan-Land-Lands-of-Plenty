library TimedBonus requires MoveSpeedBonus, AgentStruct

// TODO: Change implementation to use a Linked Hash Set instead of an array to pass parameters.

private struct TimerDataReal extends array
    
    implement AgentStruct

    method operator[] takes integer i returns real
        return thistype.getChildTable(this).real[i]
    endmethod
    
    method operator[]= takes integer i, real value returns nothing
        set thistype.getChildTable(this).real[i] = value
    endmethod
    
    method has takes integer i returns boolean
        return thistype.getChildTable(this).real.has(i)
    endmethod
endstruct

private struct TimerData extends array

    implement AgentStruct
    
    method operator[] takes integer i returns integer 
        return thistype.getChildTable(this)[i]
    endmethod
    
    method operator[]= takes integer i, integer value returns nothing
        set thistype.getChildTable(this)[i] = value
    endmethod
    
    method has takes integer i returns boolean
        return thistype.getChildTable(this).has(i)
    endmethod
    
    method operator unit takes nothing returns unit
        return thistype.getChildTable(this).unit[-1]
    endmethod
    
    method operator unit= takes unit whichUnit returns nothing
        set thistype.getChildTable(this).unit[-1] = whichUnit
    endmethod
    
    method operator real takes nothing returns TimerDataReal
        return this
    endmethod
endstruct

function TimedBonusTimerFunc takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local TimerData tId = TimerData.get(t)
    local unit timerUnit = tId.unit
    local integer bonusType = 0
    
    if null != timerUnit then  // Do nothing is unit has been removed from the game

        loop
        exitwhen bonusType>10
            if tId.has(bonusType) then
                call CSS_AddBonus(timerUnit, -tId[bonusType] , bonusType)
            endif
            set bonusType = bonusType + 1
        endloop
        
        if tId.real.has(bonusType) then
            call GMSS_UnitAddMoveSpeed(timerUnit, -tId.real[bonusType])
        endif
        if tId.real.has(bonusType+1) then
            call GMSS_UnitMultiplyMoveSpeed(timerUnit, 1./tId.real[bonusType + 1])
        endif
    endif
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call tId.destroy()

    set t = null
    set timerUnit = null
endfunction

function AddTimedBonus takes unit whichUnit, real moveAdd, real moveMul, real duration returns nothing
    local integer bonusType = 0
    local timer t = CreateTimer()
    local TimerData tId = TimerData.get(t)

    loop
    exitwhen bonusType>10
        if udg_TimerBonuses[bonusType] != 0 then
            call CSS_AddBonus(whichUnit, udg_TimerBonuses[bonusType] , bonusType)
            set tId[bonusType] = udg_TimerBonuses[bonusType]
            set udg_TimerBonuses[bonusType] = 0
        endif
        set bonusType = bonusType + 1
    endloop

    if moveAdd != 0 then
        set tId.real[bonusType] = moveAdd
        call GMSS_UnitAddMoveSpeed(whichUnit, moveAdd)
    endif
    if moveMul > 0 and moveMul != 1 then
        set tId.real[bonusType + 1]  = moveMul
        call GMSS_UnitMultiplyMoveSpeed(whichUnit, moveMul)
    endif

    set tId.unit = whichUnit
    call TimerStart(t, duration, false, function TimedBonusTimerFunc)
    
    set t = null
endfunction

endlibrary
