scope CommandsSave

private function EnumFilter takes nothing returns boolean
    return not (RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) and not LoP_IsUnitDummy(GetFilterUnit()))
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local LoP_PlayerData pId = GetPlayerId(trigP)
    local unit generator = GUDR_PlayerGetSelectedGenerator(trigP)
    local SaveInstance saveInstance
    
    if generator == null then
        set saveInstance = SaveInstance.create(SaveWriter.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments()))

        set saveInstance.unit.effects = EnumDecorationsOfPlayer(trigP)
        
        set saveInstance.unit.units = CreateGroup()
        call GroupEnumUnitsOfPlayer(saveInstance.unit.units, trigP, Filter(function EnumFilter))
        call LoP_EnumNeutralUnits(trigP, saveInstance.unit.units)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), saveInstance.unit.units)  // Order matters, protected units may be in neutral group
        
        call SaveUnits(saveInstance)
        call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, pId.realName + ( " has started saving units."))
        set generator = null
    else
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.WARNING, "Since you are selecting a Rect Generator, the |cffffff00-asav|r command will be run instead. Only things inside the rect will be saved.")
        call LoPCommands_ExecuteCommand("-asav " + LoP_Command.getArguments())
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Save takes nothing returns nothing
    call LoP_Command.create("-save", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
