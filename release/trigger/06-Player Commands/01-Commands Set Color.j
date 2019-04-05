function ForGroup_ChangeColor takes nothing returns nothing
    if GUMSGetUnitColor(GetEnumUnit()) == "D" then
        call SetUnitColor(GetEnumUnit(), GUMS_I2PlayerColor(udg_System_PlayerColor[GetPlayerId(GetTriggerPlayer())+1]))
    endif
endfunction

function Trig_Commands_Toggle_Autoname_Copy_Actions takes nothing returns nothing
    local integer color = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
    local group g = CreateGroup()
    local player p = GetTriggerPlayer()
    
    set udg_System_PlayerColor[GetPlayerId(p)+1] = color
    
    call GroupEnumUnitsOfPlayer(g, p, null)
    call ForGroup(g, function ForGroup_ChangeColor)
    call DestroyGroup(g)
    set g = null
endfunction

//===========================================================================
function InitTrig_Commands_Set_Color takes nothing returns nothing
    set gg_trg_Commands_Set_Color = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Set_Color, function Trig_Commands_Toggle_Autoname_Copy_Actions )
endfunction

