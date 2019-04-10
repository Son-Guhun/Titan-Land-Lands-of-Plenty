function Trig_CommandsD_Set_Tree_Space_Conidtions takes nothing returns boolean
    local real value = S2R(LoP_Command.getArguments())
    set udg_TreeSystem_Space[GetConvertedPlayerId(GetTriggerPlayer())] = RMaxBJ(value, 0.)
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_Tree_Space takes nothing returns nothing
    call LoP_Command.create("-space", ACCESS_USER, Condition(function Trig_CommandsD_Set_Tree_Space_Conidtions))
endfunction

