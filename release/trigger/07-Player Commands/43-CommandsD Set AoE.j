constant function MAX_VAL_SIZE takes nothing returns integer
    return 10
endfunction


function Trig_CommandsD_Set_AoE_Conditions takes nothing returns boolean
    local integer value = R2I(Arguments_ParseNumber(LoP_Command.getArguments()))
    local player trigP = GetTriggerPlayer()
    local group g
    local unit u
    local integer count = 0
    local integer totalCount = LoP.H.CountPlayerUnitsOfType(trigP, DECO_BUILDER_SPECIAL)
    
    set udg_DecoSystem_Value[GetPlayerId(trigP) + 1] = IMaxBJ(IMinBJ(value, MAX_VAL_SIZE()), 1)
    
    if totalCount > 0 then
        set g = CreateGroup()
        call GroupEnumUnitsOfPlayer(g, trigP, null)
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if GetUnitTypeId(u) == DECO_BUILDER_SPECIAL then
                call LoPDecoBuilders_AdjustSpecialAbilities(u)
                set count = count + 1
                exitwhen count == totalCount
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_AoE takes nothing returns nothing
    call LoP_Command.create("-val", ACCESS_USER, Condition(function Trig_CommandsD_Set_AoE_Conditions))
endfunction

