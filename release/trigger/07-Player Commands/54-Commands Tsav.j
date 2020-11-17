scope CommandsTsav

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local SaveWriter saveWriter
    local unit generator
    
    set generator =  GUDR_PlayerGetSelectedGenerator(trigP)
    if generator != null then
        set saveWriter = SaveWriter.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments())
        set saveWriter.centerX = GetUnitX(generator)
        set saveWriter.centerY = GetUnitY(generator)
        set saveWriter.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveWriter.extentY = GUDR_GetGeneratorExtentY(generator)
        
        call SaveTerrain(SaveInstance.create(saveWriter), GUDR_GetGeneratorRect(generator))
        call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.SYSTEM, LoP_PlayerData(User[GetTriggerPlayer()]).realName + ( " has started saving terrain."))
        set generator = null
    else
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "You must be selecting a Rect Generator.")
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Tsav takes nothing returns nothing
    call LoP_Command.create("-tsav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
