function SaveFilter takes nothing returns boolean
    local destructable dest = GetFilterDestructable()
    if  IsDestructableTree(dest) and udg_save_localPlayerBool then
        call Preload(I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- Save_GetCenterX(udg_temp_integer))+"|"+R2S(GetDestructableY(dest)- Save_GetCenterY(udg_temp_integer))+"|")
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
        call Preload("-load dest")
        set udg_save_localPlayerBool = true
        set tempInteger = udg_temp_integer
        set udg_temp_integer = playerNumber
    endif
    call EnumDestructablesInRect(rectangle, Condition(function SaveFilter), null)
    if GetLocalPlayer() == saver then
        call PreloadGenEnd("DataManager\\" + udg_save_password[playerNumber+1] + "\\0.txt")
        call SaveSize(udg_save_password[playerNumber+1], 1)
        set udg_save_localPlayerBool = false
        set udg_temp_integer = tempInteger
    endif
    call DisplayTextToPlayer( saver,0,0, "Finished Saving" )
    
    set rectangle = null
endfunction

//===========================================================================
function InitTrig_SaveLoop_Dest takes nothing returns nothing
    set gg_trg_SaveLoop_Dest = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveLoop_Dest, function SaveLoopActions2 )
endfunction

