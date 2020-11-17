scope CommandsDsav

private function onCommand takes nothing returns boolean
    local player saver = GetTriggerPlayer()
    local unit generator
    local SaveWriter saveWriter
    
    set generator =  GUDR_PlayerGetSelectedGenerator(saver)
    if generator != null then
        set saveWriter = SaveWriter.create(saver, SaveNLoad_FOLDER() + LoP_Command.getArguments())
        set saveWriter.centerX = GetUnitX(generator)
        set saveWriter.centerY = GetUnitY(generator)
        set saveWriter.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveWriter.extentY = GUDR_GetGeneratorExtentY(generator)
    
        call SaveDestructables(SaveInstance.create(saveWriter), GUDR_GetGeneratorRect(generator))
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
