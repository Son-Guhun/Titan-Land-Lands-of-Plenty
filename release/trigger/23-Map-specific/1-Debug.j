// This function is used to easily print debug messages only if a certain condition is met.
// Boolean parameter is on front because the message might be big.
// I know this clashes with the function's name, but it should be better this way.
// Example usage:
//debug call Debug_PrintIf(IsUnitDeadBJ(whichUnit), GetUnitName(whichUnit)+ " is DEAD!"
library LoPDebug
function Debug_PrintIf takes boolean condition, string message returns nothing
    if condition then
        call BJDebugMsg(message)
    endif
endfunction
endlibrary
