constant function MAX_VAL_SIZE takes nothing returns integer
    return 10
endfunction


function Trig_CommandsD_Set_AoE_Actions takes nothing returns nothing
    local integer value
    
    if Commands_StartsWithCommand() then
        set value = S2I(Commands_GetArguments())
        
        if value < MAX_VAL_SIZE() then
            set udg_DecoSystem_Value[GetPlayerId(GetTriggerPlayer()) + 1] = value
        else
            set udg_DecoSystem_Value[GetPlayerId(GetTriggerPlayer()) + 1] = MAX_VAL_SIZE()
        endif
    endif
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_AoE takes nothing returns nothing
    set gg_trg_CommandsD_Set_AoE = CreateTrigger(  )
    call TriggerAddAction( gg_trg_CommandsD_Set_AoE, function Trig_CommandsD_Set_AoE_Actions )
endfunction

