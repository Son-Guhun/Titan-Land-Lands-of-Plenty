scope CommandsDsav

private function onCommand takes nothing returns boolean
    local player saver = GetTriggerPlayer()
    local unit generator
    local SaveData saveData
    
    set generator =  GUDR_PlayerGetSelectedGenerator(saver)
    if generator != null then
        set saveData = SaveData.create(saver, SaveNLoad_FOLDER() + LoP_Command.getArguments())
        set saveData.centerX = GetUnitX(generator)
        set saveData.centerY = GetUnitY(generator)
        set saveData.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveData.extentY = GUDR_GetGeneratorExtentY(generator)
    
        call SaveDestructables(saveData, GUDR_GetGeneratorRect(generator))
        call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.SYSTEM, LoP_PlayerData(User[GetTriggerPlayer()]).realName + ( " has started saving trees."))
        set generator = null
    else
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "You must be selecting a Rect Generator.")
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Dsav takes nothing returns nothing
    call LoP_Command.create("-dsav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
