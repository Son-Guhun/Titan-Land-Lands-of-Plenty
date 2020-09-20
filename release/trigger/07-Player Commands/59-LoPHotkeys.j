library LoPHotkeys initializer Init requires LoPCommands, ConstTable

private struct G extends array

    private static key hashTable
    
    static method operator table takes nothing returns ConstHashTable  // might need to return a HashTable in the future
        return hashTable
    endmethod

endstruct

private function Register takes integer metaKey, OSKeys key, string cmd returns nothing
    call key.register()
    set G.table[metaKey].string[key] = cmd
endfunction

private function onKey takes nothing returns boolean
    local integer key = GetHandleId(BlzGetTriggerPlayerKey())
    local integer metaKey = BlzGetTriggerPlayerMetaKey()
    
    if BlzGetTriggerPlayerIsKeyDown() then
        call LoPCommands_ExecuteCommand(G.table[metaKey].string[key])
    endif
    
    return true
endfunction

private function Init takes nothing returns nothing
    call OSKeys.addListener(Condition(function onKey))
    
    call Register(MetaKeys.SHIFT, OSKeys.U, "-select no")
    call Register(MetaKeys.SHIFT, OSKeys.BACKSPACE, "-remove")
    call Register(MetaKeys.SHIFT, OSKeys.C, "-collision off")
    
    
    call Register(MetaKeys.SHIFT+MetaKeys.CTRL, OSKeys.C, "-collision on")
    
    
    call Register(MetaKeys.ALT, OSKeys.R, "-rect mouse")
    call Register(MetaKeys.ALT, OSKeys.W, "-start mouse")
    call Register(MetaKeys.ALT, OSKeys.Q, "-controller mouse")
    
    
endfunction


endlibrary