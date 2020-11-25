library AnyTileDefinition /* v1.2b    By IcemanBo - Credits to WaterKnight
                             
               
   */ requires /*
        */ TableStruct             /*
        
        */ optional WorldBounds    /* github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j  
 
 
  ====  Config variable added by Guhun ==== */
 globals
    
    // If you do not use these functions, setting this to false will spare you 2 global variables and an init function
    // Requires WorldBounds.
    private constant boolean ENABLE_ID_FUNCTIONS = true

endglobals



function GetCustomTileCenterCoordinate takes integer tileSize, real a returns real
    return I2R(MathRound(a/tileSize)*tileSize)
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

static if ENABLE_ID_FUNCTIONS and LIBRARY_WorldBounds then

    private struct Globals extends array
        //! runtextmacro TableStruct_NewConstTableField("","totalX")
        //! runtextmacro TableStruct_NewConstTableField("","totalY")
    endstruct
        
    function GetCustomTileId takes integer tileSize, real x, real y returns integer
        local integer halfTileSize = tileSize/2
        return ((R2I(x - WorldBounds.minX + halfTileSize) / tileSize) * Globals.totalY[tileSize] + R2I(y - WorldBounds.minY + halfTileSize) / tileSize)
    endfunction
    
    /* Normally the first and last tiles lines in the map are only half-sized (like terrain tiles).
    This function handles tiles like pathing tiles, which are always fully sized. */
    function GetCustomTileIdOffset takes integer tileSize, real x, real y returns integer
        return ((R2I(x - WorldBounds.minX) / tileSize) * Globals.totalY[tileSize] + R2I(y - WorldBounds.minY) / tileSize)
    endfunction
    
    function GetCustomTileIdSafe takes integer tileSize, real x, real y returns integer
        local integer halfTileSize = tileSize/2
        
        if x > WorldBounds.maxX then
            set x = WorldBounds.maxX 
        elseif x < WorldBounds.minX then
            set x = WorldBounds.minX
        endif
        
        if y > WorldBounds.maxY then
            set y = WorldBounds.maxY
        elseif y < WorldBounds.minY then
            set y = WorldBounds.minY
        endif
    
        return ((R2I(x - WorldBounds.minX + halfTileSize) / tileSize) * Globals.totalY[tileSize] + R2I(y - WorldBounds.minY + halfTileSize) / tileSize)
    endfunction

    function IsValidCustomTileId takes integer tileSize, integer id returns boolean
        return (id > 0) and (id <= Globals.totalX[tileSize] * Globals.totalY[tileSize])
    endfunction

    function GetCustomTileCenterXById takes integer tileSize, integer id returns real
        return I2R(WorldBounds.minX + id/Globals.totalY[tileSize] * tileSize)
    endfunction

    function GetCustomTileCenterYById takes integer tileSize, integer id returns real
        return I2R(WorldBounds.minY + ModuloInteger(id, Globals.totalY[tileSize]) * tileSize)
    endfunction
    
    function GetCustomTileHorizontalCount takes integer tileSize returns integer
        return Globals.totalX[tileSize]
    endfunction
    
    function GetCustomTileVerticalCount takes integer tileSize returns integer
        return Globals.totalY[tileSize]
    endfunction
    
    function ValidateCustomTileIndexI takes integer tileSize, integer i returns boolean
        return Globals.totalY.integer[tileSize] > i
    endfunction
    
    function ValidateCustomTileIndexJ takes integer tileSize, integer j returns boolean
        return Globals.totalX.integer[tileSize] > j
    endfunction
    
    function GetCustomTileIndexI takes integer tileId, integer tileSize returns integer
        return ModuloInteger(tileId, Globals.totalY[tileSize])
    endfunction
    
    function GetCustomTileIndexJ takes integer tileId, integer tileSize returns integer
        return tileId / Globals.totalY[tileSize]
    endfunction
        
    
    function GetCustomTileIdFromIndices takes integer i, integer j, integer tileSize returns integer
        return i + j*Globals.totalY[tileSize]
    endfunction
    
    public function IntRoundUp takes integer num, integer multiple returns integer
        return ((num-1)/multiple + 1)*multiple
    endfunction
    
    function GetCustomTileIdLastVertical takes integer tileSize, integer tileId returns integer
        return IntRoundUp(tileId, Globals.totalY[tileSize]) - 1
    endfunction

    function InitCustomTiles takes integer tileSize returns nothing
        if not Globals.totalX.has(tileSize) then
            set Globals.totalX[tileSize] = R2I(WorldBounds.maxX - WorldBounds.minX) / tileSize + 1
            set Globals.totalY[tileSize] = R2I(WorldBounds.maxY - WorldBounds.minY) / tileSize + 1
        endif
    endfunction
    
    // These text macros can be used to loop over tiles that overlap with a certain rect.
    //! textmacro TilesInRectLoopDeclare takes varName, tileSize, minX, minY, maxX, maxY
        local integer $varName$ = GetCustomTileIdSafe(($tileSize$), ($minX$), ($minY$))
        local integer tilesInRect_maxI = GetCustomTileIdSafe(($tileSize$), ($maxX$), ($maxY$))
        local integer tilesInRect_verticalCount = tilesInRect_maxI - GetCustomTileIdSafe(($tileSize$), ($maxX$), ($minY$))
        local integer tilesInRect_maxJ = $varName$ + tilesInRect_verticalCount
    //! endtextmacro

    //! textmacro TilesInRectLoop takes varName, tileSize
        if $varName$ == tilesInRect_maxJ then
            set tilesInRect_maxJ = $varName$ + GetCustomTileVerticalCount(($tileSize$))
            exitwhen tilesInRect_maxJ > tilesInRect_maxI
            set $varName$ = tilesInRect_maxJ - tilesInRect_verticalCount
        else
            set $varName$ = $varName$ + 1
        endif
    //! endtextmacro

    /// Doc /////////////////
    // Example for usage of the above textmacros:
    //! novjass
    function TilesInRectLoopExample takes integer tileSize, real minX, real minY, real maxX, real maxY returns nothing
        //! runtextmacro TilesInRectLoopDeclare("i", "tileSize", "minX", "minY", "maxX", "maxY")
        
        
        loop
            // do stuff here
                    
            
            
            //! runtextmacro TilesInRectLoop("i", "tileSize")
        endloop
    endfunction
    //! endnovjass
    ////////////////////////////
    
endif

   
endlibrary