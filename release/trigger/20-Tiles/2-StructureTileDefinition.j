library StructureTileDefinition /* v1.2b    By Guhun - Credits to IcemanBo and to WaterKnight
               
   */ requires /*

        */ optional WorldBounds    /* github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j  
               
**
**
**                          Information
**                         _____________
**
**  StrcutureTileDefinition provides an API to give information about a a structure tile.
**            
**      
**                             API
**                           _______
**
**
**
**      function Get64TileCenterCoordinate takes real a returns real
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
   
    function Get64TileCenterCoordinate takes real a returns real
        if (a >= 0.) then
            return R2I(((a)/64) + .5)*64. - 32
        else
            return R2I(((a)/64) - .5)*64. + 32
        endif
    endfunction
    
    function Get64TileMin takes real a returns real
        return Get64TileCenterCoordinate(a) - 32.
    endfunction
   
    function Get64TileMax takes real a returns real
        return Get64TileCenterCoordinate(a) + 32.
    endfunction
    
    function AreCoordinatesInSame64Tile takes real a, real b returns boolean
        return Get64TileCenterCoordinate(a) == Get64TileCenterCoordinate(b)
    endfunction
   
    function AreLocationsInSame64Tile takes real x1, real y1, real x2, real y2 returns boolean
        return AreCoordinatesInSame64Tile(x1, x2) and AreCoordinatesInSame64Tile(y1, y2)
    endfunction
    
    
   
endlibrary