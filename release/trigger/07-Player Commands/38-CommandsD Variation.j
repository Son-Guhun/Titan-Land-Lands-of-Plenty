function Trig_CommandsD_Variation_Conditions takes nothing returns boolean
    set udg_TileSystem_Var[GetPlayerId(GetTriggerPlayer())+1] = IMinMax(-1, S2I(LoP_Command.getArguments()), 17)
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Variation takes nothing returns nothing
    call LoP_Command.create("-var", ACCESS_USER, Condition(function Trig_CommandsD_Variation_Conditions))
endfunction

