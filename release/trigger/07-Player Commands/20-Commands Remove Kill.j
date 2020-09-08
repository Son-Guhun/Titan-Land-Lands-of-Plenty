function Trig_Commands_Remove_Kill_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    local unit u
    local integer i
    local player trigP = GetTriggerPlayer()
    local boolean remove = LoP_Command.getCommand() == "-remove"
    local boolean GM = trigP == udg_GAME_MASTER
    
    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        if GM or LoP_PlayerOwnsUnit(trigP, u) then
            if remove then
                call LoP_RemoveUnit(u)
            else
                call LoP_KillUnit(u)
            endif
        else
            call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
        endif
    endloop
    
    call DestroyGroup(g)
    set g = null
    set u = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Remove_Kill takes nothing returns nothing
    call LoP_Command.create("-kill", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))
    call LoP_Command.create("-remove", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))
endfunction

