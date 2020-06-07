scope CommandsTsav

private function onCommand takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local SaveData saveData
    local unit generator
    
    set generator =  GUDR_PlayerGetSelectedGenerator(trigP)
    if generator != null then
        set saveData = SaveData.create(trigP, SaveNLoad_FOLDER() + LoP_Command.getArguments())
        set saveData.centerX = GetUnitX(generator)
        set saveData.centerY = GetUnitY(generator)
        set saveData.extentX = GUDR_GetGeneratorExtentX(generator)
        set saveData.extentY = GUDR_GetGeneratorExtentY(generator)
        
        call SaveTerrain(saveData, GUDR_GetGeneratorRect(generator))
        set generator = null
    endif
    
    return true
endfunction

//===========================================================================
function InitTrig_Commands_Tsav takes nothing returns nothing
    call LoP_Command.create("-tsav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
