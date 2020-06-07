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
        set generator = null
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Dsav takes nothing returns nothing
    call LoP_Command.create("-dsav", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
