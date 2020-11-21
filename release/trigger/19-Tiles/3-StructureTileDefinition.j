library StructureTileDefinition /* v1.2b    By Guhun - Credits to IcemanBo and to WaterKnight
               
   */ requires /*

        */ optional WorldBounds    /* github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j  
               
**
**
**                          Information
**                         _____________
**
**  StrcutureTileDefinition provides an API to give information about a structure tile.
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
        return MathRound((a+32)/64)*64. - 32
    endfunction
   
endlibrary