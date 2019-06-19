function SaveFilter takes nothing returns boolean
    local destructable dest = GetFilterDestructable()
    local string saveStr
    
    if  IsDestructableTree(dest) then
        set saveStr = SaveNLoad_FormatString("SnL_dest",  I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- Save_GetCenterX(udg_temp_integer))+"|"+R2S(GetDestructableY(dest)- Save_GetCenterY(udg_temp_integer))+"|")
        if udg_save_localPlayerBool then
            call Preload(saveStr)
        endif
    endif
    set dest = null
    return false
endfunction

function SaveLoopActions2 takes nothing returns nothing
    local player saver = GetTriggerPlayer()
    local integer genId
    local rect rectangle
    local integer playerNumber = GetPlayerId(saver)
    local integer tempInteger
    local string saveStr
    
    if SubString(GetEventPlayerChatString(), 0, 6) != "-dsav " then
        return
    endif
    
    set udg_save_password[playerNumber+1] = SubString(GetEventPlayerChatString(), 6, 129)
    
    set genId =  GUDR_PlayerGetSelectedGeneratorId(saver)
    if genId == 0 then
        return
    endif

    
    
    set rectangle = GUDR_GetGeneratorIdRect(genId)
    if GetLocalPlayer() == saver then
        call PreloadGenClear()
        call PreloadGenStart()
        set udg_save_localPlayerBool = true
        set tempInteger = udg_temp_integer  // store global value in local
        set udg_temp_integer = playerNumber
    endif
    call EnumDestructablesInRect(rectangle, Condition(function SaveFilter), null)
    
    set saveStr = "DataManager\\" + udg_save_password[playerNumber+1] + "\\0.txt"
    if GetLocalPlayer() == saver then
        call PreloadGenEnd(saveStr)
        set udg_save_localPlayerBool = false
        set udg_temp_integer = tempInteger  // restore global variable value
    endif
    call SaveSize(saver, udg_save_password[playerNumber+1], 1)
    
    call DisplayTextToPlayer( saver,0,0, "Finished Saving" )
    
    set rectangle = null
endfunction

//===========================================================================
function InitTrig_SaveDestructable takes nothing returns nothing
    set gg_trg_SaveDestructable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveDestructable, function SaveLoopActions2 )
endfunction

