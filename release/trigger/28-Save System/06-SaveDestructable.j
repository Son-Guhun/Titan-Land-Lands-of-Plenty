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
