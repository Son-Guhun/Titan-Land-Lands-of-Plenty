function SaveTiles takes nothing returns boolean
        local integer i
        local string saveStr
        local integer playerNumber = GetPlayerId(GetTriggerPlayer())
        set i = 0
        set saveStr = "@"
        loop
        exitwhen i >= 60
            if udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS] then
                set i = 121
            else
                set saveStr = saveStr + LoadD2H(GUMS_GetTerrainTileIndex(GetTerrainType(udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS],udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS]))) + LoadD2H(GetTerrainVariance(udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS],udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS]))
            endif
            set i = i+1
            if udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] then
                set udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] + 128
                set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber]
                //call BJDebugMsg("Switch")
            else
                set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] + 128
            endif
        endloop

        if GetLocalPlayer() == GetTriggerPlayer() then
            call Preload(saveStr)
        endif
    return false
endfunction

function SaveTerrain takes nothing returns nothing
    local integer i
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())
    local string saveStr
    local triggercondition cond
    local rect saveRect
    local integer genId
    
    if SubString(GetEventPlayerChatString(), 0, 6) != "-tsav " then
        return
    endif
    
    set genId =  GUDR_PlayerGetSelectedGeneratorId(GetTriggerPlayer())
    if genId == 0 then
        return
    endif
    
    set saveRect = GUDR_GetGeneratorIdRect(genId)
    set udg_save_XYminmaxcur[playerNumber] = GetRectMinX(saveRect)
    set udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] = GetRectMaxX(saveRect)
    set udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS] = GetRectMinY(saveRect)
    set udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS] = GetRectMaxY(saveRect)
    set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber]
    set udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS]
    if GetLocalPlayer()== GetTriggerPlayer() then
        call PreloadGenClear()
        call PreloadGenStart()
        call Preload("-load ter")
        call Preload(R2S(udg_save_XYminmaxcur[playerNumber]) + "@" + R2S(udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS]) + "@" + R2S(udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS]) + "@" + R2S(udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS]) + "@")
        //call BJDebugMsg("Saving Terrain")
    endif
    set udg_save_password[playerNumber+1] = SubString(GetEventPlayerChatString(), 6, 129)
    set cond = TriggerAddCondition(gg_trg_SaveLoop_Terrain, Condition(function SaveTiles))
    loop
    exitwhen udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS]
        
        call TriggerEvaluate(gg_trg_SaveLoop_Terrain)
        
    endloop
    call TriggerRemoveCondition(gg_trg_SaveLoop_Terrain, cond)
    
    if GetLocalPlayer() == GetTriggerPlayer() then
        call PreloadGenEnd("DataManager\\" + udg_save_password[playerNumber+1] + "\\0.txt")
        call SaveSize(udg_save_password[playerNumber+1], 1)
        //call BJDebugMsg("Finished Saving")
    endif
    call DisplayTextToPlayer( Player(playerNumber),0,0, "Finished Saving" )
    
    set cond = null
    set saveRect = null
endfunction


//===========================================================================
function InitTrig_SaveLoop_Terrain takes nothing returns nothing
    set gg_trg_SaveLoop_Terrain = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveLoop_Terrain, function SaveTerrain )
endfunction

