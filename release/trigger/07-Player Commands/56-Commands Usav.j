scope CommandsUsav

private struct G extends array
    private static key static_members_key
    
    //! runtextmacro TableStruct_NewStaticHandleField("userRect", "rect")
    //! runtextmacro TableStruct_NewStaticHandleField("userUnits", "group")
    
    static method clear takes nothing returns nothing
        call TableStruct.type(thistype.static_members_key).flush()
    endmethod
endstruct

private function EnumFilter takes nothing returns boolean
    return RectContainsUnit(G.userRect, GetFilterUnit()) and not LoP_IsUnitDummy(GetFilterUnit())
endfunction

private function FilterNeutrals takes nothing returns nothing
    local unit enumU = GetEnumUnit()
    if RectContainsUnit(G.userRect, enumU) and not LoP_IsUnitDummy(enumU) then
        call GroupAddUnit(G.userUnits, enumU)
    endif
    set enumU = null
endfunction

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local LoP_PlayerData pId = GetPlayerId(trigP)
    local unit generator = GUDR_PlayerGetSelectedGenerator(trigP)
    local SaveWriter saveData = SaveWriter.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments())
    local SaveInstance saveInstance = SaveInstance.create(saveData)
    
    set G.userUnits = CreateGroup()
    set saveInstance.unit.units = G.userUnits
    
    if generator == null then
        call GroupEnumUnitsSelected(G.userUnits, trigP, null)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), G.userUnits)
    else
        set G.userRect = GUDR_GetGeneratorIdRect(GetHandleId(generator))
    
        set saveInstance.unit.effects = EnumDecorationsOfPlayerInRect(trigP, GetRectMinX(G.userRect), GetRectMinY(G.userRect), GetRectMaxX(G.userRect), GetRectMaxY(G.userRect))
        
        call GroupEnumUnitsOfPlayer(G.userUnits, trigP, Filter(function EnumFilter))
        call LoP_ForNeutralUnits(trigP, function FilterNeutrals)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), G.userUnits)  // Order matters, protected units may be in neutral group
        
        set saveData.centerX = GetUnitX(generator)
        set saveData.centerY = GetUnitY(generator)
        set saveData.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveData.extentY = GUDR_GetGeneratorExtentY(generator)
        
        call G.clear()
        set generator = null
    endif
    
    call SaveUnits(saveInstance)
    call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.SYSTEM, pId.realName + ( " has started saving units."))
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Usav takes nothing returns nothing
    call LoP_Command.create("-usav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
