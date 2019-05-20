library AnyTileDefinition /* v1.2b    By IcemanBo - Credits to WaterKnight
                             
               
   */ requires /*

        */ optional WorldBounds    /* github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j  
 
 
  ====  Config variable added by Guhun ==== */
 globals
    
    // If you do not use these functions, setting this to false will spare you 2 global variables and an init function
    // Requires WorldBounds.
    private constant boolean ENABLE_ID_FUNCTIONS = true

endglobals



function GetCustomTileCenterCoordinate takes integer tileSize, real a returns real
    if (a >= 0.) then
        return I2R(R2I((a/tileSize) + .5)*tileSize)
    else
        return I2R(R2I((a/tileSize) - .5)*tileSize)
    endif
endfunction

function AreCoordinatesInSameCustomTile takes integer tileSize, real a, real b returns boolean
    return GetCustomTileCenterCoordinate(tileSize, a) == GetCustomTileCenterCoordinate(tileSize, b)
endfunction

function AreLocationsInSameCustomTile takes integer tileSize, real x1, real y1, real x2, real y2 returns boolean
    return GetCustomTileCenterCoordinate(tileSize,x1) == GetCustomTileCenterCoordinate(tileSize,x2) and /*
         */GetCustomTileCenterCoordinate(tileSize,y1) == GetCustomTileCenterCoordinate(tileSize,y2)
endfunction

function GetCustomTileMin takes integer tileSize, real a returns real
    return GetCustomTileCenterCoordinate(tileSize, a) - tileSize/2
endfunction

function GetCustomTileMax takes integer tileSize, real a returns real
    return GetCustomTileCenterCoordinate(tileSize, a) + tileSize/2
endfunction


//! textmacro Define_AreCoordinatesInSameCustomTile_Wrapper takes tileSize
    function AreCoordinatesInSame$tileSize$Tile takes real a, real b returns boolean
        return GetCustomTileCenterCoordinate($tileSize$,a) == GetCustomTileCenterCoordinate($tileSize$,b)
    endfunction
    
    function Get$tileSize$TileMin takes real a returns real
        GetCustomTileCenterCoordinate($tileSize$, a) - $halfTileSize$
    endfunction
    
    function Get$tileSize$TileMax takes real a returns real
        GetCustomTileCenterCoordinate($tileSize$, a) + $halfTileSize$
    endfunction
//! endtextmacro

private struct Globals extends array
    //! runtextmacro TableStruct_NewConstTableField("","totalX")
    //! runtextmacro TableStruct_NewConstTableField("","totalY")
endstruct
    
    
function GetCustomTileId takes integer tileSize, real x, real y returns integer
    local integer halfTileSize = tileSize/2
    return ((R2I(x - WorldBounds.minX + halfTileSize) / tileSize) * Globals.totalX[tileSize] + R2I(y - WorldBounds.minY + halfTileSize) / tileSize)
endfunction

function IsValidCustomTileId takes integer tileSize, integer id returns boolean
    return (id < 0) or (id >= Globals.totalX[tileSize] * Globals.totalY[tileSize])
endfunction

function GetCustomTileCenterXById takes integer tileSize, integer id returns real
    return I2R(WorldBounds.minX + ModuloInteger(id, Globals.totalX[tileSize]) * tileSize)
endfunction

function GetCustomTileCenterYById takes integer tileSize, integer id returns real
    return I2R(WorldBounds.minY + id / Globals.totalX[tileSize] * tileSize)
endfunction

function InitCustomTiles takes integer tileSize returns nothing
    if not Globals.totalX.has(tileSize) then
        set Globals.totalX[tileSize] = R2I(WorldBounds.maxX - WorldBounds.minX) / tileSize + 1
        set Globals.totalY[tileSize] = R2I(WorldBounds.maxY - WorldBounds.minY) / tileSize + 1
    endif
endfunction

   
endlibrary