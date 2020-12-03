library LoPHotkeys initializer Init requires LoPCommands, ConstTable
/*
========
Description
========

    This library provides a simple way to map hotkeys to the execution of a command + arguments.
    
========
Cofiguration
========
*/
//! textmacro LoPHotkeys_Mappings
    call Register(MetaKeys.SHIFT, OSKeys.U, "-select no")
    call Register(MetaKeys.SHIFT, OSKeys.BACKSPACE, "-remove")
    call Register(MetaKeys.SHIFT, OSKeys.C, "-collision off")
    
    
    call Register(MetaKeys.SHIFT+MetaKeys.CTRL, OSKeys.C, "-collision on")
    
    
    call Register(MetaKeys.ALT, OSKeys.R, "-rect mouse")
    call Register(MetaKeys.ALT, OSKeys.W, "-start mouse")
    call Register(MetaKeys.ALT, OSKeys.Q, "-controller mouse")
    call Register(MetaKeys.ALT, OSKeys.Z, "-fullscreen")
    
    call Register(MetaKeys.CTRL, OSKeys.F, "-freecam")
//! endtextmacro
// ========================
// Source Code
// ========================

// G.table is a HashTable => G.table[metaKey] is a table mapping all OSKeys to strings, which are commands.
// G.table[MetaKeys.ALT].string[OSKeys.Q] is equal to the string that will be executed as a command when Alt+Q is pressed.
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
    
    if BlzGetTriggerPlayerIsKeyDown() and G.table[metaKey].string.has(key) then
        call LoPCommands_ExecuteCommand(G.table[metaKey].string[key])
    endif
    
    return true
endfunction

private function Init takes nothing returns nothing
    call OSKeys.addListener(Condition(function onKey))
    
    //! runtextmacro LoPHotkeys_Mappings()
endfunction


endlibrary