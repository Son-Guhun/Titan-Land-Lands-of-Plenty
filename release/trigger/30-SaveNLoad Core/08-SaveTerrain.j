library SaveTerrain requires SaveNLoadTerrain, SaveNLoadProgressBars, LoPWarn
/*
    Defines the SaveTerrain function:
    
        function SaveTerrain takes SaveWriter saveWriter, rect rectangle returns nothing
        
    This function is used for saving terrain. When it is called, the rect's dimensions are saved
in memory. Every 0.5 seconds, tiles from this rect are saved (starting from the bottomleft corner)
until the entire rect has been traversed. If this function is called while saving is in progress
or the owner of saveWriter, then saving is cancelled and the player is warned.

*/

struct SaveInstanceTerrain extends array

    static constant integer BATCH_SIZE = 25  // Number of strings saved per saveNextTiles call (increasing will reduce FPS in-game and may cause OP limit issues)
    static constant integer TILES_PER_STRING = 30  // 30 tiles per single string (avoid desync). If we were not saving height data, we could double this value.

    implement ExtendsTable
    implement SaveInstanceBaseModule
    
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("minX", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("minY", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("maxX", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("maxY", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("curX", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("curY", "real")
    
    method initialize takes rect saveRect returns nothing
        local SaveWriter saveWriter = .saveWriter
        
        set .minX = GetTileMin(GetRectMinX(saveRect))
        set .maxX = GetTileCenterCoordinate(GetRectMaxX(saveRect))
        set .minY = GetTileMin(GetRectMinY(saveRect))
        set .maxY = GetTileCenterCoordinate(GetRectMaxY(saveRect))
        set .curX = .minX
        set .curY = .minY
        
        if User.Local == saveWriter.player then
            call BlzFrameSetText(saveProgressBarText, "Waiting...")
            call BlzFrameSetValue(saveProgressBar, 0.)
            call BlzFrameSetVisible(saveProgressBar, true)
        endif
    endmethod
    
    method isInitialized takes nothing returns boolean
        return .minX_exists()
    endmethod
    
    method isFinished takes nothing returns boolean
        return not .isInitialized() or (.curY > .maxY)
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
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", SerializeTerrainHeader(saveWriter, .minX, .minY, .maxX, .maxY)))
        endif

        loop
        exitwhen j >= BATCH_SIZE or curY > maxY  
            set saveStr = ""
            set i = 0
            
            loop
            exitwhen i >= TILES_PER_STRING
                
                set saveStr = saveStr + SerializeTerrainTile(curX, curY)
                
                set i = i+1
                set curX = curX + 128
                if curX > maxX then
                    set curY = curY + 128
                    set curX = .minX
                    exitwhen curY > maxY
                endif
            endloop
            
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", saveStr))
            set j = j + 1
        endloop
        
        if curY > maxY then
            call saveWriter.write(SaveNLoad_FormatString("SnL_ter", "end"))
            call DisplayTextToPlayer(saveWriter.player, 0, 0, "Finished Saving")
        else
            if User.Local == saveWriter.player then
                call BlzFrameSetValue(saveProgressBar, 100.*((curY-.minY)*(maxX-.minX) + (maxX - curX)) / ((maxY-.minY)*(maxX-.minX)))
                call BlzFrameSetText(saveProgressBarText, I2S(R2I((curY-.minY)*(maxX-.minX)+(maxX - curX))/16384) + "/" + I2S(R2I((maxY-.minY)*(maxX-.minX))/16384))
            endif
        endif

        set .curX = curX
        set .curY = curY
    endmethod
    
endstruct
endlibrary
