library SaveDestructable requires SaveNLoad, SaveIO, GLHS, LoPWarn
/*
    Defines the SaveDestructables function:
    
        function SaveDestructables takes SaveData saveData, rect rectangle returns nothing
        
    This function is used for saving destructables. When it is called, all destructables inside the
Rect are saved into a list. Every 0.5 seconds, 60 destructables in this list are saved, until the
list is empty. If this function is called while saving is in progress for the owner of saveData, then
saving is cancelled and the player is warned.

*/

private struct PlayerData extends array
    static key static_members_key
    //! runtextmacro TableStruct_NewStaticStructField("playerQueue", "LinkedHashSet")

    //! runtextmacro TableStruct_NewStructField("saveData", "SaveData")
    //! runtextmacro TableStruct_NewStructField("destructables", "ArrayList_destructable")
    //! runtextmacro TableStruct_NewPrimitiveField("current", "integer")


    static method operator enumPlayerId takes nothing returns integer
        return bj_forLoopAIndex
    endmethod
    
    static method operator enumPlayerId= takes integer val returns nothing
        set bj_forLoopAIndex = val
    endmethod
endstruct

private function SaveNextDestructables takes PlayerData playerId returns nothing
    local integer i = playerId.current
    local ArrayList_destructable destructables = playerId.destructables
    local integer final = IMinBJ(i + 60, destructables.size)
    local destructable dest
    local SaveData saveData = playerId.saveData

    loop
    exitwhen i == final
        set dest = destructables[i]
        if IsDestructableTree(dest) then
            call saveData.write(SaveNLoad_FormatString("SnL_dest",  I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- saveData.centerX)+"|"+R2S(GetDestructableY(dest)- saveData.centerY)+"|"))
        endif
        set i = i + 1
    endloop
    
    set playerId.current = i 
    set dest = null
endfunction

private function onTimer takes nothing returns nothing
    local PlayerData playerId 
    
    if not PlayerData.playerQueue.isEmpty() then
        set playerId = PlayerData.playerQueue.getFirst() - 1
        call PlayerData.playerQueue.remove(playerId+1)
        
        call SaveNextDestructables(playerId)
        if playerId.current == playerId.destructables.size then
            call playerId.saveData.destroy()
            set playerId.saveData = 0
            call playerId.destructables.clear()
            call DisplayTextToPlayer(Player(playerId),0,0, "Finished Saving" )
        else
            call PlayerData.playerQueue.append(playerId+1)
        endif
    endif
endfunction

private function AddToArrayList takes nothing returns boolean
    call PlayerData(PlayerData.enumPlayerId).destructables.append(GetFilterDestructable())
    return false
endfunction

function SaveDestructables takes SaveData saveData, rect rectangle returns nothing
    local integer tempInteger
    local PlayerData playerId = GetPlayerId(saveData.player)
    
    if playerId.saveData != 0 then
        call LoP_WarnPlayer(saveData.player, LoPChannels.WARNING, "Did not finish saving previous file!")
        call playerId.saveData.destroy()
        call playerId.destructables.clear()
    else
        call PlayerData.playerQueue.append(playerId+1)
    endif
    set playerId.saveData = saveData
    set playerId.current = 0

    set tempInteger = PlayerData.enumPlayerId  // store global value in local
    set PlayerData.enumPlayerId = playerId

    call EnumDestructablesInRect(rectangle, Condition(function AddToArrayList), null)
    
    set PlayerData.enumPlayerId = tempInteger  // restore global variable value
endfunction

//===========================================================================
function InitTrig_SaveDestructable takes nothing returns nothing
    local PlayerData playerId = 0

    call TimerStart(CreateTimer(), 0.5, true, function onTimer)
    
    set PlayerData.playerQueue = LinkedHashSet.create()
    loop
    exitwhen playerId == bj_MAX_PLAYER_SLOTS
        if GetPlayerController(Player(playerId)) == MAP_CONTROL_USER then
            set playerId.destructables = ArrayList.create()
        endif
        set playerId = playerId + 1
    endloop
endfunction

endlibrary
