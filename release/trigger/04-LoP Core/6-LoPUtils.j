library LoPUtils

function IMinMax takes integer min, integer value, integer max returns integer
    return IMaxBJ(min, IMinBJ(value, max))
endfunction

function RMinMax takes real min, real value, real max returns real
    return RMaxBJ(min, RMinBJ(value, max))
endfunction


endlibrary