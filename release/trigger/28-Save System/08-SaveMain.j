library SaveMain requires TileDefinition, SaveIO, SaveUnit, LoPWarn
/*
    This library defines functionality to save a group of units and effects using SaveIO over time. Due
to performance issues, saving all units instantly is not a good idea, as that will lag the game and may
cause disconnects.

Calling the SaveUnits function will schedule saving for a player. Every 0.5 seconds, units and effects in
the SaveUnit_PlayerData fields "effects" and "units" will be saved, 25 units at a time. This library
also handles cases where a save is made while another is not finished. In this case, the previous save
is terminated and a warning is shown to the player.

The same principles used in this library are used for SaveUnit and SaveDestructable libraries. Since
those libraries are simpler, it might be easier to understand them first before looking at this library.

This is a fairly LoP-specific implementation, though it could easily be adapted to work elsewhere.
*/


struct SaveInstance//  extends array


    implement SaveInstanceBaseModule
    
    
    static method create takes SaveWriter saveWriter returns thistype
        local thistype this = allocate()
    
        set SaveInstanceBase(this).saveWriter = saveWriter
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call .saveWriter.destroy()
        
        if .unit.units != null then
            call DestroyGroup(.unit.units)
        endif
        if .unit.effects != null then
            call .unit.effects.destroy()
        endif
    endmethod
    


    method operator unit takes nothing returns SaveInstanceUnit
        return this
    endmethod
    
    

    ArrayList_destructable  destructables
    // maxX
    // maxY
    // minX
    // minY

endstruct

private struct PlayerData extends array
    //! runtextmacro TableStruct_NewStaticStructField("playerQueue", "LinkedHashSet")

    implement DebugPlayerStruct
    
    static key static_members_key
    //! runtextmacro TableStruct_NewStructField("saveInstance", "SaveInstance")
endstruct


private function SaveLoopActions takes nothing returns nothing
    local PlayerData playerId
    local LinkedHashSet queue = PlayerData.playerQueue
    
    if not queue.isEmpty() then
        call BJDebugMsg("Attempting to save")
        set playerId = queue.getFirst() - 1
        call queue.remove(playerId+1)
        
        if not IsGroupEmpty(playerId.saveInstance.unit.units) or not playerId.saveInstance.unit.effects.isEmpty() then
            call BJDebugMsg("Units to save found")
            call BJDebugMsg(I2S(BlzGroupGetSize(playerId.saveInstance.unit.units)))
            call playerId.saveInstance.unit.saveNextUnits()
        else
            call playerId.saveInstance.destroy()
        endif
    
        // if playerId.isSaving then
            call queue.append(playerId+1)
        // endif
    endif
endfunction

function SaveUnits takes SaveInstance saveInstance returns nothing
    local SaveWriter saveWriter = saveInstance.saveWriter
    local PlayerData playerId = GetPlayerId(saveWriter.player)


    // set playerId.isSaving = true
    call saveInstance.unit.initialize()
    
    if playerId.saveInstance != 0 then
        call LoP_WarnPlayer(saveWriter.player, LoPChannels.WARNING, "Did not finish saving previous file!")
        call playerId.saveInstance.destroy()
    else
        call PlayerData.playerQueue.append(playerId + 1)
    endif
    set playerId.saveInstance = saveInstance
    
    
    if User.fromLocal() == playerId then
        call BlzFrameSetText(saveUnitBarText, "Waiting...")
        call BlzFrameSetVisible(saveUnitBar, true)
        call BlzFrameSetValue(saveUnitBar, 0.)
    endif
endfunction

private struct InitStruct
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.5, true, function SaveLoopActions)
        set PlayerData.playerQueue = LinkedHashSet.create()
    endmethod
endstruct

endlibrary