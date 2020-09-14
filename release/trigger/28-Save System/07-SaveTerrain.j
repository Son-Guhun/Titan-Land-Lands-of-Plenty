library SaveTerrain requires SaveNLoad, SaveIO, SaveNLoadProgressBars

//! textmacro SaveXYMethodTerrain takes name
    method operator $name$ takes nothing returns real
        return SaveNLoad_PlayerData(this).terrain.$name$
    endmethod
    
    method operator $name$= takes real value returns nothing
        set SaveNLoad_PlayerData(this).terrain.$name$ = value
    endmethod
//! endtextmacro

private struct PlayerData extends array
    static key static_members_key
    //! runtextmacro TableStruct_NewStaticStructField("playerQueue", "LinkedHashSet")
    static method isInitialized takes nothing returns boolean
        return playerQueueExists()
    endmethod

    //! runtextmacro TableStruct_NewStructField("saveData", "SaveData")
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
    local string heightStr
    local real maxX = playerId.maxX
    local real maxY = playerId.maxY
    local integer j = 0
    local SaveData saveData = playerId.saveData

    loop
    exitwhen j >= 25 /* avoid OP limit */ or curY > maxY  
        set saveStr = ""
        set i = 0
        
        loop
        exitwhen i >= 30 // 30 tiles per single string (avoid desync)
            
            set saveStr = saveStr + LoadD2H(TerrainTools_GetTextureId(GetTerrainType(curX, curY)))/*
                                */+ LoadD2H(GetTerrainVariance(curX, curY))
                                
            set heightStr = AnyBase(92).encode(Deformation.fromCoords(curX, curY).idepth + SaveNLoad_BASE_92_OFFSET())
            if StringLength(heightStr) == 1 then
                set saveStr = saveStr + ("0" + heightStr)
            else
                set saveStr = saveStr + heightStr
            endif
            
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

/*
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
*/

private function onTimer takes nothing returns nothing
    local PlayerData playerId
    
    if not PlayerData.playerQueue.isEmpty() then
        set playerId = PlayerData.playerQueue.getFirst() - 1
        call PlayerData.playerQueue.remove(playerId+1)
    
        call SaveTiles(playerId)
        if playerId.curY > playerId.maxY then
            call playerId.saveData.write(SaveNLoad_FormatString("SnL_ter", "end"))
            call playerId.saveData.destroy()
            set playerId.saveData = 0
            call DisplayTextToPlayer( Player(playerId),0,0, "Finished Saving" )
            if User.fromLocal() == playerId then
                call BlzFrameSetVisible(saveTerrainBar, false)
            endif
        else
            call PlayerData.playerQueue.append(playerId+1)
            if User.fromLocal() == playerId then
                call BlzFrameSetValue(saveTerrainBar, 100.*((playerId.curY-playerId.minY)*(playerId.maxX-playerId.minX) + (playerId.maxX - playerId.curX)) / ((playerId.maxY-playerId.minY)*(playerId.maxX-playerId.minX)))
                call BlzFrameSetText(saveTerrainBarText, I2S(R2I((playerId.curY-playerId.minY)*(playerId.maxX-playerId.minX)+(playerId.maxX - playerId.curX))/16384) + "/" + I2S(R2I((playerId.maxY-playerId.minY)*(playerId.maxX-playerId.minX))/16384))
            endif
        endif
    endif
endfunction

function SaveTerrain takes SaveData saveData, rect saveRect returns nothing
    local PlayerData playerId = GetPlayerId(saveData.player)
    
    if not PlayerData.isInitialized() then  // avoid creating an extra function
        set PlayerData.playerQueue = LinkedHashSet.create()
    endif

    if playerId.saveData != 0 then
        call DisplayTextToPlayer(playerId.saveData.player, 0., 0., "|cffff0000Warning:|r Did not finish saving previous file!")
        call playerId.saveData.destroy()
    else
        call PlayerData.playerQueue.append(playerId+1)
    endif
    set playerId.saveData = saveData
    
    set playerId.minX = GetRectMinX(saveRect)
    set playerId.maxX = GetRectMaxX(saveRect)
    set playerId.minY = GetRectMinY(saveRect)
    set playerId.maxY = GetRectMaxY(saveRect)
    set playerId.curX = playerId.minX
    set playerId.curY = playerId.minY
    
    call saveData.write(SaveNLoad_FormatString("SnL_ter", "=" + R2S(playerId.minX - saveData.centerX) + "@" + R2S(playerId.maxX - saveData.centerX) + "@" +/*
                                                        */R2S(playerId.minY - saveData.centerY) + "@" + R2S(playerId.maxY - saveData.centerY) + "@"))
    
    
    if User.fromLocal() == playerId then
        call BlzFrameSetText(saveTerrainBarText, "Waiting...")
        call BlzFrameSetValue(saveTerrainBar, 0.)
        call BlzFrameSetVisible(saveTerrainBar, true)
    endif
endfunction

//===========================================================================
function InitTrig_SaveTerrain takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.5, true, function onTimer)
endfunction

endlibrary
