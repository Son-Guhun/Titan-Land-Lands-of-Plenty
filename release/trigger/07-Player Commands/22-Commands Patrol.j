scope CommandsPatrol

private function onCommand takes nothing returns boolean
    local group selectedGrp = CreateGroup()
    local unit u
    local integer i
    local player trigP = GetTriggerPlayer()
    local string args = LoP_Command.getArguments()

    call GroupEnumUnitsSelected(selectedGrp, trigP, null)
    
    set i = BlzGroupGetSize(selectedGrp)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "selectedGrp")
        
        if LoP_PlayerOwnsUnit(trigP, u) then
            if args == "clear" then
                call Patrol_ClearUnitData(u)
            elseif args == "resume" then
                call Patrol_ResumePatrol(u)
            endif
        else
            call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
        endif
        
    endloop
    
    call DestroyGroup(selectedGrp)
    set selectedGrp = null
    set u = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Patrol takes nothing returns nothing
    call LoP_Command.create("-patrol", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope