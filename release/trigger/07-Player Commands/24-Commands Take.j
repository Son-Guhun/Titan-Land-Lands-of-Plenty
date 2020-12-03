function Trig_Commands_Take_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local player trigP = GetTriggerPlayer()
    local User pId = User[trigP]
    local group g = CreateGroup()
    local unit u
    local integer i
    
    if ( args == "all" ) then
        call LoP_EnumNeutralUnits(trigP, g)
        set i = IMinBJ(BlzGroupGetSize(g), 2000)
        loop
            //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
            
            // Only return unit if it still belongs to neutral passive. Otherwise it was given to another player.
            if (GetOwningPlayer(u) == LoP.NEUTRAL_PASSIVE) then
                call SetUnitOwner(u, trigP, false)
            endif
        endloop
    else
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
        
        set i = BlzGroupGetSize(g)  // IMinBJ(BlzGroupGetSize(g), 2000)  // does not work in this case because you would always enumarate the same number of units
        loop
            //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
            
            
            if (GetOwningPlayer(u) == LoP.NEUTRAL_PASSIVE) then
                if LoP_GetOwningPlayer(u) == trigP then
                    call SetUnitOwner(u, trigP, false)
                else
                    call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This unit is not your unit.")
                endif
            else
                call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.INVALID, 0., "This unit is not neutral.")
            endif
        endloop
        

    endif
    
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Take takes nothing returns nothing
    call LoP_Command.create("-take", ACCESS_USER, Condition(function Trig_Commands_Take_Conditions))
endfunction

