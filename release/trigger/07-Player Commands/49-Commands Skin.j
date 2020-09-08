scope CommandsSkin

private function OnCommand_GroupEnum takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args ==  "get" then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., ID2S(BlzGetUnitSkin(GetFilterUnit())))
    elseif args == "default" then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., ID2S(GetUnitTypeId(GetFilterUnit())))
    elseif args == "reset" then
        if LoP_PlayerOwnsUnit(GetTriggerPlayer(), GetFilterUnit()) then
            call BlzSetUnitSkin(GetFilterUnit(), GetUnitTypeId(GetFilterUnit()))
        endif
    else
        if LoP_PlayerOwnsUnit(GetTriggerPlayer(), GetFilterUnit()) then
            call BlzSetUnitSkin(GetFilterUnit(), S2ID(args))
        endif
    endif
    
    return false
endfunction

private function OnCommand takes nothing returns boolean
    call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Filter(function OnCommand_GroupEnum ))
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Skin takes nothing returns nothing
    call LoP_Command.create("-skin", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope