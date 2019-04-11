scope CommandsSetLimits

private struct StringConvert extends array
    
    //! runtextmacro TableStruct_NewConstTableField("private","data")
    
    static method operator[] takes string s returns integer
        return data[StringHash(s)]
    endmethod
    static method operator[]= takes string s, integer value returns nothing
        set data[StringHash(s)] = value
    endmethod
    static method has takes string s returns boolean
        return data.has(StringHash(s))
    endmethod

endstruct

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma = CutToCharacter(args, " ")
    local string unitType
    local integer value
    
    if cutToComma < StringLength(args) then
        set unitType = SubString(args, 0, cutToComma)
        set value = S2I(SubString(args, cutToComma+1, StringLength(args)))
        
        if StringConvert.has(unitType) then
            set udg_System_PArmyLimit[StringConvert[unitType]] = value
            call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "Unit limit set for " + Limit_GetCategoryName(StringConvert[unitType]) + ".")
        else
            call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "Unrecognized argument: " + unitType)
        endif
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Set_Limits_for_Units takes nothing returns nothing
    call LoP_Command.create("-limit", ACCESS_TITAN, Condition(function onCommand))

    set StringConvert["p"] = PlayerUnitLimit_PASSIVE
    set StringConvert["g"] = PlayerUnitLimit_GROUND
    set StringConvert["a"] = PlayerUnitLimit_AIR
endfunction
endscope

