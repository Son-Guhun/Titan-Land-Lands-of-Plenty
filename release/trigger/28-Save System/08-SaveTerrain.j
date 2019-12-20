scope SaveTrigger

//! textmacro SaveXYMethodTerrain takes name
    method operator $name$ takes nothing returns real
        return SaveNLoad_PlayerData(this).terrain.$name$
    endmethod
    
    method operator $name$= takes real value returns nothing
        set SaveNLoad_PlayerData(this).terrain.$name$ = value
    endmethod
//! endtextmacro

private struct PlayerData extends array
    SaveData saveData
    //! runtextmacro SaveXYMethodTerrain("minX")
    //! runtextmacro SaveXYMethodTerrain("maxX")
    //! runtextmacro SaveXYMethodTerrain("curX")
    //! runtextmacro SaveXYMethodTerrain("minY")
    //! runtextmacro SaveXYMethodTerrain("maxY")
    //! runtextmacro SaveXYMethodTerrain("curY")
endstruct

function SaveTiles takes PlayerData playerId returns boolean
    local real curX = playerId.curX
    local real curY = playerId.curY
    local integer i
    local string saveStr
    local real maxX = playerId.maxX
    local real maxY = playerId.maxY
    local integer j = 0
    local SaveData saveData = playerId.saveData

    loop
    exitwhen j >= 25 /* avoid OP limit */ or curY > maxY  
        set saveStr = "@"
        set i = 0
        
        loop
        exitwhen i >= 60 // 60 tiles per single string (avoid desync)
            
            set saveStr = saveStr + LoadD2H(TerrainTools_GetTextureId(GetTerrainType(curX, curY)))/*
                                */+ LoadD2H(GetTerrainVariance(curX, curY))
            
            set i = i+1
            if curX > maxX then
                set curY = curY + 128
                set curX = playerId.minX
                exitwhen curY > maxY
            else
                set curX = curX + 128
            endif
        endloop
        
        call saveData.write(SaveNLoad_FormatString("SnL_ter", saveStr))
        set j = j + 1
    endloop

    set playerId.curX = curX
    set playerId.curY = curY
        
    return false
endfunction

private function onTimer takes nothing returns nothing
    local PlayerData playerId = 0
    
    loop
    exitwhen playerId == bj_MAX_PLAYER_SLOTS
        if playerId.saveData != 0 then
            call SaveTiles(playerId)
            if playerId.curY > playerId.maxY then
                call playerId.saveData.destroy()
                set playerId.saveData = 0
                call DisplayTextToPlayer( Player(playerId),0,0, "Finished Saving" )
            endif
        endif
        set playerId = playerId + 1
    endloop
endfunction

function SaveTerrain takes nothing returns nothing
    local integer i
    local PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local rect saveRect
    local unit generator
    
    if SubString(GetEventPlayerChatString(), 0, 6) != "-tsav " then
        return
    endif
    
    set generator =  GUDR_PlayerGetSelectedGenerator(Player(playerId))
    if generator == null then
        return
    endif
    set saveRect = GUDR_GetGeneratorRect(generator)
    
    if playerId.saveData != 0 then
        call playerId.saveData.destroy()
    endif
    
    set playerId.saveData = SaveData.create(GetTriggerPlayer(), SaveNLoad_FOLDER() + SubString(GetEventPlayerChatString(), 6, 129))
    set playerId.saveData.centerX = GetUnitX(generator)
    set playerId.saveData.centerY = GetUnitY(generator)
    set playerId.saveData.extentX = GUDR_GetGeneratorExtentX(generator)
    set playerId.saveData.extentY = GUDR_GetGeneratorExtentY(generator)
    
    set saveRect = GUDR_GetGeneratorRect(generator)
    set playerId.minX = GetRectMinX(saveRect)
    set playerId.maxX = GetRectMaxX(saveRect)
    set playerId.minY = GetRectMinY(saveRect)
    set playerId.maxY = GetRectMaxY(saveRect)
    set playerId.curX = playerId.minX
    set playerId.curY = playerId.minY
    
    call playerId.saveData.write(SaveNLoad_FormatString("SnL_ter", R2S(playerId.minX - playerId.saveData.centerX) + "@" + R2S(playerId.maxX - playerId.saveData.centerX) + "@" +/*
                                                        */R2S(playerId.minY - playerId.saveData.centerY) + "@" + R2S(playerId.maxY - playerId.saveData.centerY) + "@"))
    
    set saveRect = null
    set generator = null
endfunction


//===========================================================================
function InitTrig_SaveTerrain takes nothing returns nothing
    set gg_trg_SaveTerrain = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveTerrain, function SaveTerrain )
    call TimerStart(CreateTimer(), 0.5, true, function onTimer)
endfunction

endscope
