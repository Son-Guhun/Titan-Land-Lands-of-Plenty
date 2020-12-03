library SaveNLoadTerrain requires SaveNLoad, TerrainTools, Deformations, DeformationToolsHooks
/*
    Defines functions used for loading terrain into the game.

*/

function LoadD2H takes integer int returns string
    return SubString(AnyBase.digits,int,int+1)
endfunction

function LoadH2D takes string char returns integer
    return AnyBase.getDigitValue(char)
endfunction

constant function SaveNLoad_BASE_92_OFFSET takes nothing returns integer
    return 4232
endfunction

function IsTerrainHeader takes string chatStr returns boolean
    return not (SubString(chatStr, 0, 1) == "@")
endfunction

function IsTerrainHeaderV7 takes string chatStr returns boolean
    return SubString(chatStr, 0, 1) == "="
endfunction

scope Serialization
    function SerializeTerrainHeader takes SaveWriter saveWriter, real minX, real minY, real maxX, real maxY returns string
        return "=" + R2S(minX - saveWriter.centerX) + "@" + R2S(maxX - saveWriter.centerX) + "@" +/*
                   */R2S(minY - saveWriter.centerY) + "@" + R2S(maxY - saveWriter.centerY) + "@"
    endfunction
    
    function SerializeTerrainTile takes real x, real y returns string
        local string textureStr = LoadD2H(TerrainTools_GetTextureId(GetTerrainType(x, y))) + LoadD2H(GetTerrainVariance(x, y))
        local string heightStr = AnyBase(92).encode(Deformation.fromCoords(x, y).idepth + SaveNLoad_BASE_92_OFFSET())
                                    
        if StringLength(heightStr) == 1 then
            return textureStr + ("0" + heightStr)
        else
            return textureStr + heightStr
        endif
    endfunction

endscope


scope DeSerialization

    //! textmacro SaveXYMethod takes name, offset
        method operator $name$ takes nothing returns real
            return udg_save_XYminmaxcur[this$offset$]
        endmethod
        
        method operator $name$= takes real value returns nothing
            set udg_save_XYminmaxcur[this$offset$] = value
        endmethod
    //! endtextmacro

    private struct PlayerTerrainData extends array
        //! runtextmacro SaveXYMethod("minX", "")
        //! runtextmacro SaveXYMethod("maxX", "+bj_MAX_PLAYERS")
        //! runtextmacro SaveXYMethod("curX", "+2*bj_MAX_PLAYERS")
        //! runtextmacro SaveXYMethod("minY", "+3*bj_MAX_PLAYERS")
        //! runtextmacro SaveXYMethod("maxY", "+4*bj_MAX_PLAYERS")
        //! runtextmacro SaveXYMethod("curY", "+5*bj_MAX_PLAYERS")
        
        
    endstruct

    // Loads the first line of a terrain save, which contains the coords of the rect
    // offsetIsCenter indicates that offsetX and offsetY should be interpreted as the coords of a new center for the rect, and not actual offsets. Used for version 3 saves.
    function LoadTerrainHeader takes PlayerTerrainData playerId, string chatStr, real offsetX, real offsetY, boolean offsetIsCenter, boolean beforeV8 returns nothing
        local integer cutToComma
        
        local real centerY
        local real centerX
        
        if IsTerrainHeaderV7(chatStr) then
            set chatStr = SubString(chatStr, 1, StringLength(chatStr))
        endif

        set cutToComma = CutToCharacter(chatStr,"@")
        set playerId.minX = S2I(SubString(chatStr,0,cutToComma))
        set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))

        set cutToComma = CutToCharacter(chatStr,"@")
        set playerId.maxX = S2I(SubString(chatStr,0,cutToComma))
        set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
        
        set cutToComma = CutToCharacter(chatStr,"@")
        set playerId.minY = S2I(SubString(chatStr,0,cutToComma))
        set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
        
        set cutToComma = CutToCharacter(chatStr,"@")
        set playerId.maxY = S2I(SubString(chatStr,0,cutToComma))
        
        if offsetX != 0 or offsetY != 0 then
        
            if offsetIsCenter then // old versions support
                set centerX = (playerId.minX + playerId.maxX)/2
                set centerY = (playerId.minY + playerId.maxY)/2
                set offsetX = offsetX - centerX
                set offsetY = offsetY - centerY
            endif
            
            set playerId.minX = playerId.minX + offsetX
            set playerId.maxX = playerId.maxX + offsetX
            set playerId.minY = playerId.minY + offsetY
            set playerId.maxY = playerId.maxY + offsetY
        endif

        set playerId.curX = playerId.minX
        set playerId.curY = playerId.minY
        
        if beforeV8 then
            set playerId.maxX = playerId.maxX + 128.
        endif
    endfunction

    function LoadTerrainFinish takes PlayerTerrainData playerId returns nothing    
        call DeformationToolsHooks_TagBlocks(playerId.minX, playerId.minY, playerId.maxX, playerId.maxY)
    endfunction

    function LoadTerrain takes PlayerTerrainData playerId, string chatStr returns nothing
        local integer strSize
        local integer i
        
        set strSize = StringLength(chatStr)
        if SubString(chatStr, 0, 1) == "@" then  // if string starts with @, then there is no height data
            set i = 1
            loop
            exitwhen i >= strSize
                call SetTerrainType(playerId.curX, playerId.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
                set i = i + 2
                set playerId.curX = playerId.curX + 128
                if playerId.curX > playerId.maxX then
                    set playerId.curY = playerId.curY + 128
                    set playerId.curX = playerId.minX
                endif
            endloop
        else
            set i = 0
            loop
            exitwhen i >= strSize
                call SetTerrainType(playerId.curX, playerId.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
                set Deformation.fromCoords(playerId.curX, playerId.curY).depth = AnyBase(92).decode(SubString(chatStr,i+2,i+4)) - SaveNLoad_BASE_92_OFFSET()
                set i = i + 4
                set playerId.curX = playerId.curX + 128
                if playerId.curX > playerId.maxX then
                    set playerId.curY = playerId.curY + 128
                    set playerId.curX = playerId.minX
                endif
            endloop
        endif

    endfunction
endscope

endlibrary