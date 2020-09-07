library WorldBoundsUtils requires WorldBounds

    function CoordX takes real coord returns real
        if coord > WorldBounds.maxX then
            return I2R(WorldBounds.maxX)
        elseif coord < WorldBounds.minX then
            return I2R(WorldBounds.minX)
        else
            return coord
        endif
    endfunction
    
    function CoordY takes real coord returns real
        if coord >= WorldBounds.maxY then
            return I2R(WorldBounds.maxY)
        elseif coord < WorldBounds.minY then
            return I2R(WorldBounds.minY)
        else
            return coord
        endif
    endfunction

    function IsPointValid takes real x, real y returns boolean
        return x >= WorldBounds.minX and x <= WorldBounds.minY and y >= WorldBounds.minY and y <= WorldBounds.maxY
    endfunction

endlibrary