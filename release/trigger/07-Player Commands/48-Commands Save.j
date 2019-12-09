scope CommandsSave

private function EnumFilter takes nothing returns boolean
    return not (RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) and GetUnitTypeId(GetFilterUnit()) != 'h07Q' /*dummy unit*/)
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local SaveUnit_PlayerData playerData = GetPlayerId(trigP)

    set playerData.effects = EnumDecorationsOfPlayer(trigP)
    if playerData.units == null then
        set playerData.units = CreateGroup()
    endif
    call GroupEnumUnitsOfPlayer(playerData.units, trigP, Filter(function EnumFilter))
    call BlzGroupAddGroupFast(LoP_GetPlayerNeutralUnits(trigP), playerData.units)
    call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), playerData.units)  // Order matters, protected units may be in neutral group
    
    
    call SaveUnitsForPlayer(trigP, LoP_Command.getArguments())
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, LoP_PlayerData(playerData).realName + ( " has started saving."))// Expected save time: " + R2S(BlzGroupGetSize(udg_save_grp[playerNumber])/25.00)))        
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Save takes nothing returns nothing
    call LoP_Command.create("-save", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
