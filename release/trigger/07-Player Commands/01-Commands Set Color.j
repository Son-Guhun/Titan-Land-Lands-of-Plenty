function Trig_Commands_Toggle_Autoname_Copy_Actions takes nothing returns nothing
    local integer color = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
    local player p = GetTriggerPlayer()
    
    if color < 1 or color > bj_MAX_PLAYER_SLOTS then
        call LoP_PlayerData.get(p).setUnitColor(GetPlayerColor(p))
    else
        // Safety warning: ConvertPlayerColor crashes with invalid arguments.
        call LoP_PlayerData.get(p).setUnitColor(ConvertPlayerColor(color-1))
    endif
    
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, p, Filter(function Filter_UnitSetPlayerColor))
endfunction

//===========================================================================
function InitTrig_Commands_Set_Color takes nothing returns nothing
    set gg_trg_Commands_Set_Color = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Set_Color, function Trig_Commands_Toggle_Autoname_Copy_Actions )
endfunction

