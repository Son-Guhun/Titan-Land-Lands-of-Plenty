scope CommandsUsav

globals
    private rect userRect = null
    private group userUnits = null
endglobals

private function EnumFilter takes nothing returns boolean
    return RectContainsUnit(userRect, GetFilterUnit()) and GetUnitTypeId(GetFilterUnit()) != 'h07Q' /*dummy unit*/
endfunction

private function FilterNeutrals takes nothing returns nothing
    local unit enumU = GetEnumUnit()
    if RectContainsUnit(userRect, enumU) and GetUnitTypeId(enumU) != 'h07Q' then
        call GroupAddUnit(userUnits, enumU)
    endif
    set enumU = null
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local SaveUnit_PlayerData playerData = GetPlayerId(trigP)
    local integer genId
    
    if playerData.units == null then
        set playerData.units = CreateGroup()
    endif
    
    set genId = GUDR_PlayerGetSelectedGeneratorId(trigP)
    if genId == 0 then
        call GroupEnumUnitsSelected(playerData.units, trigP, null)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), playerData.units)
    else
        set userRect = GUDR_GetGeneratorIdRect(genId)
    
        set playerData.effects = EnumDecorationsOfPlayerInRect(trigP, GetRectMinX(userRect), GetRectMinY(userRect), GetRectMaxX(userRect), GetRectMaxY(userRect))
        
        set userUnits = playerData.units
        call GroupEnumUnitsOfPlayer(playerData.units, trigP, Filter(function EnumFilter))
        call ForGroup(LoP_GetPlayerNeutralUnits(trigP), function FilterNeutrals)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), playerData.units)  // Order matters, protected units may be in neutral group
    endif
    
    call SaveUnitsForPlayer(trigP, LoP_Command.getArguments())
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, LoP_PlayerData(playerData).realName + ( " has started saving."))// Expected save time: " + R2S(BlzGroupGetSize(udg_save_grp[playerNumber])/25.00)))        
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Usav takes nothing returns nothing
    call LoP_Command.create("-usav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
