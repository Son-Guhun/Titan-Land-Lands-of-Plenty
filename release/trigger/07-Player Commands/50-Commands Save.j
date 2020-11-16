scope CommandsSave

private function EnumFilter takes nothing returns boolean
    return not (RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) and not LoP_IsUnitDummy(GetFilterUnit()))
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local LoP_PlayerData pId = GetPlayerId(trigP)
    local SaveInstance saveInstance = SaveInstance.create(SaveData.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments()))

    set saveInstance.unit.effects = EnumDecorationsOfPlayer(trigP)
    
    set saveInstance.unit.units = CreateGroup()
    call GroupEnumUnitsOfPlayer(saveInstance.unit.units, trigP, Filter(function EnumFilter))
    call LoP_EnumNeutralUnits(trigP, saveInstance.unit.units)
    call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), saveInstance.unit.units)  // Order matters, protected units may be in neutral group
    
    call BJDebugMsg(I2S(BlzGroupGetSize(saveInstance.unit.units)))
    
    call SaveUnits(saveInstance)
    call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, pId.realName + ( " has started saving units."))
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Save takes nothing returns nothing
    call LoP_Command.create("-save", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
