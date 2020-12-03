function Trig_Commands_Name_Unit_Func006A takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    if ( GetOwningPlayer(enumUnit) == GetTriggerPlayer() ) then
        call LoP.UVS.Name(enumUnit, LoP_Command.getArgumentsRaw())
        /*
        if LoP_UnitData.get(enumUnit).isHeroic then
            call UnitName_SetUnitName(enumUnit, GetUnitName(enumUnit))
        endif
        */
    else
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
    endif
    set enumUnit = null
endfunction

function Trig_Commands_Name_Unit_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
    
    call ForGroup(g, function Trig_Commands_Name_Unit_Func006A )
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Name_Unit takes nothing returns nothing
    call LoP_Command.create("-nameunit", ACCESS_USER, Condition(function Trig_Commands_Name_Unit_Conditions ))
endfunction

