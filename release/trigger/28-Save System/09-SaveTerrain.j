scope SaveTrigger

globals
    private SaveData saveData
endglobals

function SaveTiles takes nothing returns boolean
        local integer playerId = GetPlayerId(GetTriggerPlayer())
        local string temp1
        local string temp2
        
        local integer i = 0
        local string saveStr = "@"

        loop
        exitwhen i >= 60 // exit loop to avoid op_limit
            if udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerId+4*bj_MAX_PLAYERS] then
                set i = 121  // exit loop, since we already traversed all of the rows
            endif
            
            set saveStr = saveStr + LoadD2H(TerrainTools_GetTextureId(GetTerrainType(udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS],/*
                                                                                  */udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS])))/*
                                */+ LoadD2H(GetTerrainVariance(udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS],udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS]))
            
            set i = i+1
            if udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerId+bj_MAX_PLAYERS] then // x cur > x min
                set udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS] + 128 // y cur = next y cur
                set udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerId] // x cur = x min
            else
                set udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS] + 128  // x cur = next x cur
            endif
        endloop

        call saveData.write(SaveNLoad_FormatString("SnL_ter", saveStr))
    return false
endfunction

function SaveTerrain takes nothing returns nothing
    local integer i
    local integer playerId = GetPlayerId(GetTriggerPlayer())
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
    
    set udg_save_password[playerId+1] = SubString(GetEventPlayerChatString(), 6, 129)
    set saveData = SaveData.create(GetTriggerPlayer(), SaveNLoad_FOLDER() + udg_save_password[playerId+1])
    
    set saveRect = GUDR_GetGeneratorIdRect(genId)
    set udg_save_XYminmaxcur[playerId] = GetRectMinX(saveRect)
    set udg_save_XYminmaxcur[playerId+bj_MAX_PLAYERS] = GetRectMaxX(saveRect)
    set udg_save_XYminmaxcur[playerId+3*bj_MAX_PLAYERS] = GetRectMinY(saveRect)
    set udg_save_XYminmaxcur[playerId+4*bj_MAX_PLAYERS] = GetRectMaxY(saveRect)
    set udg_save_XYminmaxcur[playerId+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerId]
    set udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerId+3*bj_MAX_PLAYERS]
    
    call saveData.write(SaveNLoad_FormatString("SnL_ter", R2S(udg_save_XYminmaxcur[playerId]) + "@" +/*
                                                        */R2S(udg_save_XYminmaxcur[playerId+bj_MAX_PLAYERS]) + "@" +/*
                                                        */R2S(udg_save_XYminmaxcur[playerId+3*bj_MAX_PLAYERS]) + "@" +/* 
                                                        */R2S(udg_save_XYminmaxcur[playerId+4*bj_MAX_PLAYERS]) + "@"))
    
    
    set cond = TriggerAddCondition(gg_trg_SaveTerrain, Condition(function SaveTiles))
    loop
    exitwhen udg_save_XYminmaxcur[playerId+5*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerId+4*bj_MAX_PLAYERS]
        
        call TriggerEvaluate(gg_trg_SaveTerrain)
        
    endloop
    call TriggerRemoveCondition(gg_trg_SaveTerrain, cond)
    
    call saveData.destroy()
    call DisplayTextToPlayer( Player(playerId),0,0, "Finished Saving" )
    
    set cond = null
    set saveRect = null
endfunction


//===========================================================================
function InitTrig_SaveTerrain takes nothing returns nothing
    set gg_trg_SaveTerrain = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveTerrain, function SaveTerrain )
endfunction

endscope
