library PathingTileDefinition requires AnyTileDefinition

    globals
        integer WorldPathTilesX
        integer WorldPathTilesY
    endglobals


    // ID API
    function GetPathingTileId takes  real x, real y returns integer
        return ((R2I(x - WorldBounds.minX) / 32) * WorldPathTilesY + R2I(y - WorldBounds.minY) / 32)
    endfunction
    
    function GetPathingTileIdLastVertical takes integer tileSize, integer tileId returns integer
        return AnyTileDefinition_IntRoundUp(tileId, WorldPathTilesY) - 1
    endfunction
    
    // ID Coordinate API
    function GetPathingTileCenterXById takes integer id returns real
        return I2R(16 + WorldBounds.minX + (id/WorldPathTilesY)*32)
    endfunction

    function GetPathingTileCenterYById takes integer id returns real
        return I2R(16 + WorldBounds.minY + ModuloInteger(id, WorldPathTilesY)*32)
    endfunction


    // ID Index API
    function GetPathingTileIdFromIndices takes integer i, integer j returns integer
        return i + j*WorldPathTilesY
    endfunction
    
    function ValidatePathingTileIndexI takes integer i returns boolean
        return WorldPathTilesY > i
    endfunction
    
    function ValidatePathingTileIndexJ takes integer j returns boolean
        return WorldPathTilesX > j
    endfunction
    
    function PathingTileX2J takes real x returns integer
        return R2I(x - WorldBounds.minX) / 32
    endfunction

    function PathingTileY2I takes real y returns integer
        return R2I(y - WorldBounds.minY) / 32
    endfunction

    function GetPathingTileIndexI takes integer tileId returns integer
        return ModuloInteger(tileId, WorldPathTilesY)
    endfunction
    
    function GetPathingTileIndexJ takes integer tileId returns integer
        return tileId / WorldPathTilesY
    endfunction
    
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