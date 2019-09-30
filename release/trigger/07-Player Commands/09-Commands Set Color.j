scope CommandsSetColor

private function onCommand takes nothing returns boolean
    local integer color = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local player p = GetTriggerPlayer()

    if color < 1 or color > bj_MAX_PLAYER_SLOTS then
        call LoP_PlayerData.get(p).setUnitColor(GetPlayerColor(p))
    else
        // Safety warning: ConvertPlayerColor crashes with invalid arguments.
        call LoP_PlayerData.get(p).setUnitColor(ConvertPlayerColor(color-1))
    endif
    
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, p, Filter(function Filter_UnitSetPlayerColor))  // Defined in System Set Unit Color
    call DecorationEffect.updateColorsForPlayer(GetTriggerPlayer())
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Set_Color takes nothing returns nothing
    call LoP_Command.create("-setcolor", ACCESS_USER, Condition(function onCommand))
endfunction

endscope
