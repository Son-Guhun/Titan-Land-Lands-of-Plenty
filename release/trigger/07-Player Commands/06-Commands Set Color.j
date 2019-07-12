function Trig_Commands_Toggle_Autoname_Copy_Actions takes nothing returns nothing
    local integer color = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local player p = GetTriggerPlayer()

    if color < 1 or color > bj_MAX_PLAYER_SLOTS then
        call LoP_PlayerData.get(p).setUnitColor(GetPlayerColor(p))
    else
        // Safety warning: ConvertPlayerColor crashes with invalid arguments.
        call LoP_PlayerData.get(p).setUnitColor(ConvertPlayerColor(color-1))
    endif
    
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, p, Filter(function Filter_UnitSetPlayerColor))
    call DecorationEffect.updateColorsForPlayer(GetTriggerPlayer())
endfunction

//===========================================================================
function InitTrig_Commands_Set_Color takes nothing returns nothing
    call LoP_Command.create("-setcolor", ACCESS_USER, Condition(function Trig_Commands_Toggle_Autoname_Copy_Actions ))
endfunction

