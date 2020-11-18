//! runtextmacro GAL_Generate_List("true","destructable","DestructableHandle","Handle","null")

library SaveDestructable requires SaveNLoad, SaveIO, GLHS, LoPWarn
/*
    Defines the SaveDestructables function:
    
        function SaveDestructables takes SaveWriter saveData, rect rectangle returns nothing
        
    This function is used for saving destructables. When it is called, all destructables inside the
Rect are saved into a list. Every 0.5 seconds, 60 destructables in this list are saved, until the
list is empty. If this function is called while saving is in progress for the owner of saveData, then
saving is cancelled and the player is warned.

*/

private struct G extends array
    
    static method operator enumList takes nothing returns ArrayList_destructable
        return bj_forLoopAIndex
    endmethod
    
    static method operator enumList= takes integer list returns nothing
        set bj_forLoopAIndex = list
    endmethod

endstruct

private function AddToArrayList takes nothing returns boolean
    call G.enumList.append(GetFilterDestructable())
    return false
endfunction

function ArrayListEnumDestructablesInRect takes rect rectangle returns ArrayList_destructable
    local ArrayList_destructable destructables = ArrayList.create()
    local integer tempInteger

    set tempInteger = G.enumList  // store global value in local
    set G.enumList = destructables

    call EnumDestructablesInRect(rectangle, Condition(function AddToArrayList), null)

    set G.enumList = tempInteger  // restore global variable value
        

    return destructables
endfunction

struct SaveInstanceDestructable extends array

    implement SaveInstanceBaseModule
    
    private ArrayList_destructable  destructables
    private integer current
    
    method initialize takes ArrayList_destructable dests returns nothing
        set .destructables = dests
        set .current = 0
    endmethod
    
    method destructables_exists takes nothing returns boolean
        return destructables != 0
    endmethod
    
    method isFinished takes nothing returns boolean
        return not (.destructables_exists() and .current < .destructables.size)
    endmethod
    
    method saveNextDestructables takes nothing returns nothing
        local SaveWriter saveData = .saveWriter
        local integer playerId = User[saveWriter.player]
        local integer i = .current
        local ArrayList_destructable destructables = .destructables
        local integer final = IMinBJ(i + 60, destructables.size)
        local destructable dest
        

        loop
        exitwhen i == final
            set dest = destructables[i]
            if IsDestructableTree(dest) then
                call saveData.write(SaveNLoad_FormatString("SnL_dest",  I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- saveData.centerX)+"|"+R2S(GetDestructableY(dest)- saveData.centerY)+"|"))
            endif
            set i = i + 1
        endloop
        
        set .current = i 
        set dest = null
    endmethod

endstruct

endlibrary
