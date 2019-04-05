function EnumUnitsKill takes nothing returns boolean
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() then
        call LoP_KillUnit(GetFilterUnit())
    endif
    return false
endfunction

function EnumUnitsRemove takes nothing returns boolean
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() then
        call LoP_RemoveUnit(GetFilterUnit())
    endif
    return false
endfunction

function Trig_Commands_Remove_Kill_Actions takes nothing returns nothing
    if ( GetEventPlayerChatString() == "-kill" ) then
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function EnumUnitsKill))
    else
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function EnumUnitsRemove))
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Remove_Kill takes nothing returns nothing
    set gg_trg_Commands_Remove_Kill = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Remove_Kill, function Trig_Commands_Remove_Kill_Actions )
endfunction

