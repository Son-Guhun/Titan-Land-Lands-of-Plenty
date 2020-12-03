scope CommandsAsav

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
    local SaveWriter saveData
    local SaveInstance saveInstance
    
    if generator != null then
        set saveData = SaveWriter.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments())
        set saveInstance = SaveInstance.create(saveData)
    
        set G.userRect = GUDR_GetGeneratorIdRect(GetHandleId(generator))
        set G.userUnits = CreateGroup()
        
        call GroupEnumUnitsOfPlayer(G.userUnits, trigP, Filter(function EnumFilter))
        call LoP_ForNeutralUnits(trigP, function FilterNeutrals)
        call BlzGroupRemoveGroupFast(LoP_GetProtectedUnits(), G.userUnits)  // Order matters, protected units may be in neutral group
        
        set saveInstance.unit.units = G.userUnits
        set saveInstance.unit.effects = EnumDecorationsOfPlayerInRect(trigP, GetRectMinX(G.userRect), GetRectMinY(G.userRect), GetRectMaxX(G.userRect), GetRectMaxY(G.userRect))
        
        set saveData.centerX = GetUnitX(generator)
        set saveData.centerY = GetUnitY(generator)
        set saveData.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveData.extentY = GUDR_GetGeneratorExtentY(generator)
        
        call SaveStuff(saveInstance, G.userRect, G.userRect)
        call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.SYSTEM, pId.realName + ( " has started."))
        
        call G.clear()
        set generator = null
    else
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "You must be selecting a Rect Generator.")
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Asav takes nothing returns nothing
    call LoP_Command.create("-asav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
