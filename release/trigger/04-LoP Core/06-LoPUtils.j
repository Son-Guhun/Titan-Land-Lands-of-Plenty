library LoPUtils
/*
This library defines functions that are used across the map's code, but are not related to the map's mechanics.

*/

// Returns 'value' if it is within the range [min,max]. Otherwise, returns 'min' or 'max', whichever is closer to 'value'
function IMinMax takes integer min, integer value, integer max returns integer
    return IMaxBJ(min, IMinBJ(value, max))
endfunction

// Returns 'value' if it is within the range [min,max]. Otherwise, returns 'min' or 'max', whichever is closer to 'value'
function RMinMax takes real min, real value, real max returns real
    return RMaxBJ(min, RMinBJ(value, max))
endfunction


endlibrary