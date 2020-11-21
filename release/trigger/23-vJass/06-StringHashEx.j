library StringHashEx requires Table  // by Waffle, modified by Guhun
    /*********************************************************
     *  
     * API:
     *    
     *    function StringHashEx takes string returns integer
     *        for any string parameter this function is guaranteed to return a distinct integer. (as long as you don't feed it 2^^32 strings).
     *
     *
     *********************************************************/

    globals
        private constant integer REHASH = 1222483
        private key t
    endglobals

    function StringHashEx takes string key returns integer
        local integer sh = StringHash(key)
        if Table(t).string.has(sh) then
            if Table(t).string[sh] != key then  // Loops are slow in JASS, so we avoid having to enter one
                loop
                    set sh = sh + REHASH
                    if Table(t).string.has(sh) then
                        exitwhen Table(t).string[sh] == key
                    else
                        set Table(t).string[sh] = key
                        exitwhen true
                    endif
                endloop
            endif
        else
            set Table(t).string[sh] = key
        endif
        return sh
    endfunction

endlibrary
