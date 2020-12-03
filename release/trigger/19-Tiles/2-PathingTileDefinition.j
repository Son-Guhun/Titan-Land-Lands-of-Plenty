library PathingTileDefinition requires AnyTileDefinition
/*
Pathing tiles are somewhat different from terrain tiles. They are 4 times smaller (32x32), and the first
row/column of tiles is full-sized, instead of half-sized.

*/

    globals
        integer WorldPathTilesX  // Total number of tiles in a row
        integer WorldPathTilesY  // Total number of tiles in a column
    endglobals


    /*////////////
    // ID API
    These functions are used to get tile id's from other tile id's.
    
    
    *////////////
    
    // Get the ID of the last tile in the same column as the given tileId.
    function GetPathingTileIdLastVertical takes integer tileId returns integer
        return AnyTileDefinition_IntRoundUp(tileId, WorldPathTilesY) - 1
    endfunction
    
    // Get the ID of the first tile in the same column as the given tileId.
    function GetPathingTileIdFirstVertical takes integer tileId returns integer
        return tileId / WorldPathTilesY
    endfunction
    
    // Negative results indicate an out of bounds error.
    function GetPathingTileIdAbove takes integer tileId returns integer
        local integer result = tileId + 1
        if tileId > GetPathingTileIdLastVertical(tileId) then
            return -1
        endif
        return result
    endfunction
    
    // Negative results indicate an out of bounds error.
    function GetPathingTileIdBelow takes integer tileId returns integer
        local integer result = tileId - 1
        if tileId < GetPathingTileIdFirstVertical(tileId) then
            return -1
        endif
        return result
    endfunction
    
    // Negative results indicate an out of bounds error.
    function GetPathingTileIdLeft takes integer tileId returns integer
        return tileId - WorldPathTilesY
    endfunction
    
    // Negative results indicate an out of bounds error.
    function GetPathingTileIdRight takes integer tileId returns integer
        local integer result = tileId + WorldPathTilesY
        if tileId >= WorldPathTilesX*WorldPathTilesY then
            return -1
        endif
        return result
    endfunction
    
    
    /*////////////
    // ID Index API
    These functions are used to get tile id's from i/j matrix indices and vice-versa.
    
    
    *////////////
    
    // Convert a real x coordinate to a j index.
    function PathingTileX2J takes real x returns integer
        // return MathRound(x - WorldBounds.minX) / 32
        return R2I(x - WorldBounds.minX) / 32
    endfunction

    // Convert a real y coordinate to a i index.
    function PathingTileY2I takes real y returns integer
        return R2I(y - WorldBounds.minY) / 32
        // return MathRound(y - WorldBounds.minY) / 32
    endfunction
    
    // Converts the given i and j indices into a tile id.
    function GetPathingTileIdFromIndices takes integer i, integer j returns integer
        return i + j*WorldPathTilesY
    endfunction
    
    // Returns the i index of a tile.
    function GetPathingTileIndexI takes integer tileId returns integer
        return ModuloInteger(tileId, WorldPathTilesY)
    endfunction
    
    // Returns the j index of a tile.
    function GetPathingTileIndexJ takes integer tileId returns integer
        return tileId / WorldPathTilesY
    endfunction
    
    // Check whether an integer is a valid i index for a tile or if it is out of bounds.
    function ValidatePathingTileIndexI takes integer i returns boolean
        return WorldPathTilesY > i
    endfunction
    
    // Check whether an integer is a valid j index for a tile or if it is out of bounds.
    function ValidatePathingTileIndexJ takes integer j returns boolean
        return WorldPathTilesX > j
    endfunction
    
    
    
    /*////////////
    // ID Coordinate API
    These functions are used to get tile id's from real coordinates and vice-versa.
    
    
    *////////////
    
    // Returns the tile which contains the given point.
    function GetPathingTileId takes  real x, real y returns integer
        return PathingTileX2J(x)*WorldPathTilesY + PathingTileY2I(y)  // Reversed argument order of GetPathingTileIdFromIndices
    endfunction
    
    // Returns the x coordinate at the center of a tile.
    function GetPathingTileCenterXById takes integer id returns real
        return I2R(16 + WorldBounds.minX + (id/WorldPathTilesY)*32)
    endfunction

    // Returns the y coordinate at the center of a tile.
    function GetPathingTileCenterYById takes integer id returns real
        return I2R(16 + WorldBounds.minY + ModuloInteger(id, WorldPathTilesY)*32)
    endfunction
    
    // Returns the maximum X coordinate of a tile.
    function GetPathingTileMaxXById takes integer id returns real
        return GetPathingTileCenterXById(id) + 16
    endfunction
    
    // Returns the minimum X coordinate of a tile.
    function GetPathingTileMinXById takes integer id returns real
        return GetPathingTileCenterXById(id) - 16
    endfunction
    
    // Returns the maximum Y coordinate of a tile.
    function GetPathingTileMaxYById takes integer id returns real
        return GetPathingTileCenterYById(id) + 16
    endfunction
    
    // Returns the minimum Y coordinate of a tile.
    function GetPathingTileMinYById takes integer id returns real
        return GetPathingTileCenterYById(id) - 16
    endfunction
    
    
    /*////////////
    // Initialization
    *////////////
    private module Init
        private static method onInit takes nothing returns nothing
            set WorldPathTilesX = R2I(WorldBounds.maxX - WorldBounds.minX) / 32
            set WorldPathTilesY = R2I(WorldBounds.maxY - WorldBounds.minY) / 32
        endmethod
    endmodule
    private struct InitStruct extends array
        implement Init
    endstruct

endlibrary