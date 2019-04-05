function Trig_CommandsD_Locust_Func011A takes nothing returns nothing
    if not LoP_IsUnitDecoration(GetEnumUnit()) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "Only decorations may have be unselectable." )
    elseif not LoP_PlayerOwnsUnit(GetTriggerPlayer(), GetEnumUnit()) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit." )
    elseif CheckCommandOverflow() then
        call GUMSMakeUnitUnSelectable(GetEnumUnit())
    endif
endfunction

function Trig_CommandsD_Locust_Actions takes nothing returns nothing
    local group udg_temp_group = CreateGroup()

    call Commands_EnumSelectedCheckForGenerator(udg_temp_group, GetTriggerPlayer(), null)
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 500
    call ForGroup( udg_temp_group, function Trig_CommandsD_Locust_Func011A )
    
    call DestroyGroup(udg_temp_group)
    set udg_temp_group = null
endfunction

//===========================================================================
function InitTrig_CommandsD_Locust takes nothing returns nothing
    set gg_trg_CommandsD_Locust = CreateTrigger(  )
    // call TriggerRegisterPlayerChatEvent( gg_trg_CommandsD_Locust, Player(0), "-select drag", true )
    call TriggerAddAction( gg_trg_CommandsD_Locust, function Trig_CommandsD_Locust_Actions )
endfunction

