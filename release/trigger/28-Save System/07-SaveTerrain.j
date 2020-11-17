library SaveTerrain requires SaveNLoad, SaveIO, SaveNLoadProgressBars, LoPWarn
/*
    Defines the SaveTerrain function:
    
        function SaveTerrain takes SaveWriter saveWriter, rect rectangle returns nothing
        
    This function is used for saving terrain. When it is called, the rect's dimensions are saved
in memory. Every 0.5 seconds, tiles from this rect are saved (starting from the bottomleft corner)
until the entire rect has been traversed. If this function is called while saving is in progress
or the owner of saveWriter, then saving is cancelled and the player is warned.

*/

struct SaveInstanceTerrain extends array

    implement SaveInstanceBaseModule
    
    real minX
    real minY
    real maxX
    real maxY
    real curX
    real curY
    
    method initialize takes rect saveRect returns nothing
        local SaveWriter saveWriter = .saveWriter
        
        set .minX = GetRectMinX(saveRect)
        set .maxX = GetRectMaxX(saveRect)
        set .minY = GetRectMinY(saveRect)
        set .maxY = GetRectMaxY(saveRect)
        set .curX = .minX
        set .curY = .minY
        
        if User.Local == saveWriter.player then
            call BlzFrameSetText(saveTerrainBarText, "Waiting...")
            call BlzFrameSetValue(saveTerrainBar, 0.)
            call BlzFrameSetVisible(saveTerrainBar, true)
        endif
    endmethod
    
    method minX_exists takes nothing returns boolean
        return .minX != 0
    endmethod
    
    method isFinished takes nothing returns boolean
        call BJDebugMsg(R2S(.maxX))
        call BJDebugMsg(R2S(.maxY))
        call BJDebugMsg(R2S(.curX))
        call BJDebugMsg(R2S(.curY))
        return not .minX_exists() or (.curY > .maxY)
    endmethod
    
    method saveNextTiles takes nothing returns nothing
        local real curX = .curX
        local real curY = .curY
        local real maxX = .maxX
        local real maxY = .maxY
        
        local string saveStr
        local string heightStr
        
        local integer i
        local integer j = 0
        local SaveWriter saveWriter = .saveWriter
        
        if curY == .minY and curX == .minX then
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", "=" + R2S(.minX - saveWriter.centerX) + "@" + R2S(.maxX - saveWriter.centerX) + "@" +/*
                                                    */R2S(.minY - saveWriter.centerY) + "@" + R2S(.maxY - saveWriter.centerY) + "@"))
        endif

        loop
            // call BJDebugMsg(I2S(j))
            // call BJDebugMsg(R2S(curX))
            // call BJDebugMsg(R2S(curY))
        exitwhen j >= 25 /* avoid OP limit */ or curY > maxY  
            set saveStr = ""
            set i = 0
            
            loop
            exitwhen i >= 30 // 30 tiles per single string (avoid desync). If we were not saving height data, we could double this value.
                
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
                    set curX = .minX
                    exitwhen curY > maxY
                else
                    set curX = curX + 128
                endif
            endloop
            
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", saveStr))
            set j = j + 1
        endloop
        
        if curY > maxY then
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", "end"))
            call DisplayTextToPlayer(saveWriter.player, 0, 0, "Finished Saving")
            if User.Local == saveWriter.player then
                call BlzFrameSetVisible(saveTerrainBar, false)
            endif
        else
            if User.Local == saveWriter.player then
                call BlzFrameSetValue(saveTerrainBar, 100.*((curY-.minY)*(maxX-.minX) + (maxX - curX)) / ((maxY-.minY)*(maxX-.minX)))
                call BlzFrameSetText(saveTerrainBarText, I2S(R2I((curY-.minY)*(maxX-.minX)+(maxX - curX))/16384) + "/" + I2S(R2I((maxY-.minY)*(maxX-.minX))/16384))
            endif
        endif

        set .curX = curX
        set .curY = curY
    endmethod
    
endstruct
endlibrary
