library StructureTileDefinition
/*
**
**
**                          Information
**                         _____________
**
**  StrcutureTileDefinition provides an API to give information about a structure tile. Structure tiles
** are different from terrain tiles. They are sized 64x64, and the border tiles are entirely in the map,
** instead of starting from the center coordinate.
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
**                  
**      
***********************************************************************************************************/


    function Get64TileCenterCoordinate takes real a returns real
        return MathRound((a+32.)/64.)*64. - 32.
    endfunction
   
endlibrary