function FilterUnitsKill takes nothing returns boolean
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(GetFilterUnit()) == GetTriggerPlayer() then
        call LoP_KillUnit(GetFilterUnit())
    endif
    return false
endfunction

function FilterUnitsRemove takes nothing returns boolean
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(GetFilterUnit()) == GetTriggerPlayer() then
        call LoP_RemoveUnit(GetFilterUnit())
    endif
    return false
endfunction

function Trig_Commands_Remove_Kill_Conditions takes nothing returns boolean
    if LoP_Command.getCommand() == "-kill" then
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function FilterUnitsKill))
    else
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function FilterUnitsRemove))
    endif
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Remove_Kill takes nothing returns nothing
    call LoP_Command.create("-kill", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))
    call LoP_Command.create("-remove", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))
endfunction

