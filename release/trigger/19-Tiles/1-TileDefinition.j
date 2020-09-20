library TileDefinition /* v1.2b    By IcemanBo - Credits to WaterKnight
                             
               
   */ requires /*

        */ optional WorldBounds    /* github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j  
 
 
  ====  Config variable added by Guhun ==== */
 globals
    
    // If you do not use these functions, setting this to false will spare you 2 global variables and an init function
    // Requires WorldBounds.
    private constant boolean ENABLE_ID_FUNCTIONS = true

endglobals
/*
**
**                          Information
**                         _____________
**
**  TileDefinition provides an API to give information about a terrain tile.
**            
**      
**                             API
**                           _______
**
**
**
**      function GetTileCenterCoordinate takes real a returns real
**          Returns the cooridnate for the center of the tile.
**          Works for x- and y coordiantes.
**
**
**      function GetTileMax takes real a returns real
**          Returns the max value, that is still in same terrain tile.
**          Works for x- and y coordiantes.
**                  
**
**      function GetTileMin takes real a returns real
**          Returns the min value, that is still in same terrain tile.
**          Works for x- and y coordiantes.
**
**
**      function AreCoordinatesInSameTile takes real a, real b returns boolean
**          Checks if two coordinates share the same terrain tile.
**          
**          Attention: Only makes sense if both coordinates are of same type. Or x- or y coordinates.
**                     May bring wrong result, if you compare x with y coordinates.
**
**
**      function ArePointsInSameTile takes real x1, real y1, real x2, real y2 returns boolean
**          Checks if two points share the same terrain tile.
**
**
**      funtion GetTileId takes real x, real y returns integer
**          Returns an unique index for tile of given coordinates.
**          Will return "-1" if it's invalid.
**
**      function GetTileCenterXById takes integer id returns real
**
**      function GetTileCenterYById takes integer id returns real
**                  
**      
***********************************************************************************************************/   
    function GetTileCenterCoordinate takes real a returns real
        return MathRound(a/128)*128.
    endfunction
   
    function AreCoordinatesInSameTile takes real a, real b returns boolean
        return GetTileCenterCoordinate(a) == GetTileCenterCoordinate(b)
    endfunction
   
    function AreLocationsInSameTile takes real x1, real y1, real x2, real y2 returns boolean
        return AreCoordinatesInSameTile(x1, x2) and AreCoordinatesInSameTile(y1, y2)
    endfunction
   
    function GetTileMin takes real a returns real
        return GetTileCenterCoordinate(a) - 64.
    endfunction
   
    function GetTileMax takes real a returns real
        return GetTileCenterCoordinate(a) + 64.
    endfunction
    
    static if ENABLE_ID_FUNCTIONS and LIBRARY_WorldBounds then
        globals
            integer WorldTilesX
            integer WorldTilesY
        endglobals
       
        function GetTileId takes real x, real y returns integer
            local integer xI = R2I(x - WorldBounds.minX + 64) / 128
            local integer yI = R2I(y - WorldBounds.minY + 64) / 128

            if ((xI < 0) or (xI >= WorldTilesX) or (yI < 0) or (yI >= WorldTilesY)) then
                return -1
            endif

            return (yI * WorldTilesX + xI)
        endfunction

        function GetTileCenterXById takes integer id returns real
            if ((id < 0) or (id >= WorldTilesX * WorldTilesY)) then
                return 0.
            endif

            return (WorldBounds.minX + ModuloInteger(id, WorldTilesX) * 128.)
        endfunction

        function GetTileCenterYById takes integer id returns real
            if ((id < 0) or (id >= WorldTilesX * WorldTilesY)) then
                return 0.
            endif

            return (WorldBounds.minY + id / WorldTilesX * 128.)
        endfunction
       
        private module Init
            private static method onInit takes nothing returns nothing
                set WorldTilesX = R2I(WorldBounds.maxX - WorldBounds.minX) / 128 + 1
                set WorldTilesY = R2I(WorldBounds.maxY - WorldBounds.minY) / 128 + 1
            endmethod
        endmodule
       
        private struct TileDefinition extends array
            implement Init
        endstruct
    endif
   
endlibrary