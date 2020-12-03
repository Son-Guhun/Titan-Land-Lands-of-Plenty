scope CommandsControl

private function MAX_CONTROLLED takes nothing returns integer
    return 48
endfunction

private function onCommand takes nothing returns boolean
    local group g = CreateGroup()
    local unit u
    local player trigPlayer= GetTriggerPlayer()
    local integer playerNumber = GetPlayerId(trigPlayer) + 1

    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)

    if LoP_Command.getCommand() == "-control" then
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if LoP_GetOwningPlayer(u) == trigPlayer then
                if BlzGroupGetSize(udg_Player_ControlGroup[playerNumber]) < MAX_CONTROLLED() then
                    call GroupAddUnit(udg_Player_ControlGroup[playerNumber], u)
                else
                    call LoP_WarnPlayerTimeout(trigPlayer, LoPChannels.ERROR, LoPMsgKeys.LIMIT, 0., "Control group is full (" + I2S(MAX_CONTROLLED()) + ") units)!")
                    exitwhen true
                endif
            endif
        endloop
    else  // command == control
        if LoP_Command.getArguments() == "all" then
            call GroupClear( udg_Player_ControlGroup[playerNumber] )
        else
            loop
                //! runtextmacro ForUnitInGroup("u", "g")
                if LoP_GetOwningPlayer(u) == trigPlayer then
                    call GroupRemoveUnit(udg_Player_ControlGroup[playerNumber], u)
                endif
            endloop
        endif
    endif
    
    call DestroyGroup(g)
    set g = null
    set u = null
    return true
endfunction

//===========================================================================
function InitTrig_CommandsD_Control takes nothing returns nothing
    call LoP_Command.create("-control", ACCESS_USER, Condition(function onCommand))/*
    */.createChained("-uncontrol", ACCESS_USER, Condition(function onCommand))
endfunction

endscope
