scope SaveDestructable

globals
    private SaveData saveData
endglobals

private function GetSavingPlayerId takes nothing returns SaveNLoad_PlayerData
    return udg_temp_integer
endfunction

function SaveFilter takes nothing returns boolean
    local destructable dest = GetFilterDestructable()
    local string saveStr
    
    if  IsDestructableTree(dest) then
        set saveStr = SaveNLoad_FormatString("SnL_dest",  I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- GetSavingPlayerId().centerX)+"|"+R2S(GetDestructableY(dest)- GetSavingPlayerId().centerY)+"|")
        call saveData.write(saveStr)
    endif
    
    set dest = null
    return false
endfunction

function SaveLoopActions2 takes nothing returns nothing
    local player saver = GetTriggerPlayer()
    local integer genId
    local rect rectangle
    local integer playerId = GetPlayerId(saver)
    local integer tempInteger
    
    if SubString(GetEventPlayerChatString(), 0, 6) != "-dsav " then
        return
    endif
    
    set genId =  GUDR_PlayerGetSelectedGeneratorId(saver)
    if genId == 0 then
        return
    endif

    set tempInteger = udg_temp_integer  // store global value in local
    set udg_temp_integer = playerId
    
    set saveData = SaveData.create(saver, SaveNLoad_FOLDER() + SubString(GetEventPlayerChatString(), 6, 129))
    call EnumDestructablesInRect(GUDR_GetGeneratorIdRect(genId), Condition(function SaveFilter), null)
    call saveData.destroy()

    set udg_temp_integer = tempInteger  // restore global variable value
    call DisplayTextToPlayer( saver,0,0, "Finished Saving" )
endfunction

//===========================================================================
function InitTrig_SaveDestructable takes nothing returns nothing
    set gg_trg_SaveDestructable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveDestructable, function SaveLoopActions2 )
endfunction

endscope
