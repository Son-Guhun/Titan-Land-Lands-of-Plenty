library SaveNLoadTerrain requires SaveNLoad

function LoadD2H takes integer int returns string
    return SubString(AnyBase.digits,int,int+1)
endfunction

function LoadH2D takes string char returns integer
    return AnyBase.values[StringHashEx(char)]
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

// Loads the first line of a terrain save, which contains the coords of the rect
// offsetIsCenter indicates that offsetX and offsetY should be interpreted as the coords of a new center for the rect, and not actual offsets. Used for version 3 saves.
function LoadTerrainHeader takes string chatStr, real offsetX, real offsetY, boolean offsetIsCenter returns nothing
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    local real centerY
    local real centerX
    
    if IsTerrainHeaderV7(chatStr) then
        set chatStr = SubString(chatStr, 1, StringLength(chatStr))
    endif

    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.minX = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))

    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.maxX = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.minY = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.maxY = S2I(SubString(chatStr,0,cutToComma))
    
    if offsetX != 0 or offsetY != 0 then
    
        if offsetIsCenter then // old versions support
            set centerX = (playerId.terrain.minX + playerId.terrain.maxX)/2
            set centerY = (playerId.terrain.minY + playerId.terrain.maxY)/2
            set offsetX = offsetX - centerX
            set offsetY = offsetY - centerY
        endif
        
        set playerId.terrain.minX = playerId.terrain.minX + offsetX
        set playerId.terrain.maxX = playerId.terrain.maxX + offsetX
        set playerId.terrain.minY = playerId.terrain.minY + offsetY
        set playerId.terrain.maxY = playerId.terrain.maxY + offsetY
    endif

    set playerId.terrain.curX = playerId.terrain.minX
    set playerId.terrain.curY = playerId.terrain.minY
endfunction

function LoadTerrain takes string chatStr returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer strSize
    local integer i
    
    set strSize = StringLength(chatStr)
    if SubString(chatStr, 0, 1) == "@" then  // if string starts with @, then there is no height data
        set i = 1
        loop
        exitwhen i >= strSize
            call SetTerrainType(playerId.terrain.curX, playerId.terrain.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
            set i = i + 2
            if playerId.terrain.curX > playerId.terrain.maxX then
                set playerId.terrain.curY = playerId.terrain.curY + 128
                set playerId.terrain.curX = playerId.terrain.minX
            else
                set playerId.terrain.curX = playerId.terrain.curX + 128
            endif
        endloop
    else
        set i = 0
        loop
        exitwhen i >= strSize
            call SetTerrainType(playerId.terrain.curX, playerId.terrain.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
            set Deformation.fromCoords(playerId.terrain.curX, playerId.terrain.curY).depth = AnyBase(92).decode(SubString(chatStr,i+2,i+4)) - SaveNLoad_BASE_92_OFFSET()
            set i = i + 4
            if playerId.terrain.curX > playerId.terrain.maxX then
                set playerId.terrain.curY = playerId.terrain.curY + 128
                set playerId.terrain.curX = playerId.terrain.minX
            else
                set playerId.terrain.curX = playerId.terrain.curX + 128
            endif
        endloop
    endif

endfunction

endlibrary