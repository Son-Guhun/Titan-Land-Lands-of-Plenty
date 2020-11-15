scope CommandsSave

private function EnumFilter takes nothing returns boolean
    return not (RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) and not LoP_IsUnitDummy(GetFilterUnit()))
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local SaveUnit_PlayerData playerData = GetPlayerId(trigP)

    call playerData.effects.clear()
    call EnumDecorationsOfPlayerEx(playerData.effects, trigP)
    
    call GroupEnumUnitsOfPlayer(playerData.units, trigP, Filter(function EnumFilter))
    call LoP_EnumNeutralUnits(trigP, playerData.units)
    call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), playerData.units)  // Order matters, protected units may be in neutral group
    
    
    call SaveUnits(SaveData.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments()))
    call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.SYSTEM, LoP_PlayerData(playerData).realName + ( " has started saving units."))
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Save takes nothing returns nothing
    call LoP_Command.create("-save", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
