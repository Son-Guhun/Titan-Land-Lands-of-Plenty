constant function MAX_VAL_SIZE takes nothing returns integer
    return 10
endfunction


function Trig_CommandsD_Set_AoE_Conditions takes nothing returns boolean
    local integer value = S2I(LoP_Command.getArguments())
    set udg_DecoSystem_Value[GetPlayerId(GetTriggerPlayer()) + 1] = IMaxBJ(IMinBJ(value, MAX_VAL_SIZE()), 1)
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_AoE takes nothing returns nothing
    call LoP_Command.create("-val", ACCESS_USER, Condition(function Trig_CommandsD_Set_AoE_Conditions))
endfunction

