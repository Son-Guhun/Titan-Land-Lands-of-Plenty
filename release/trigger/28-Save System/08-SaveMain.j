library SaveMain requires TileDefinition, SaveIO, SaveUnit, SaveDestructable LoPWarn
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


struct SaveInstance extends array


    implement ExtendsTable
    implement SaveInstanceBaseModule
    
    
    static method create takes SaveWriter saveWriter returns thistype
        local thistype this = Table.create()
    
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
        
        call Table(this).destroy()
    endmethod
    


    method operator unit takes nothing returns SaveInstanceUnit
        return this
    endmethod
    
    method operator destructable takes nothing returns SaveInstanceDestructable
        return this
    endmethod
    
    method operator terrain takes nothing returns SaveInstanceTerrain
        return this
    endmethod

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
    local SaveInstance saveInstance
    
    if not queue.isEmpty() then
        call BJDebugMsg("Attempting to save")
        set playerId = queue.getFirst() - 1
        set saveInstance = playerId.saveInstance
        
        call queue.remove(playerId+1)
        
        if not saveInstance.unit.isFinished() then
            call BJDebugMsg("Units to save found")
            call BJDebugMsg(I2S(BlzGroupGetSize(saveInstance.unit.units)))
            call saveInstance.unit.saveNextUnits()
            
        elseif not saveInstance.destructable.isFinished() then
            call BJDebugMsg("Destructables to save found")
            call saveInstance.destructable.saveNextDestructables()
            
        elseif not saveInstance.terrain.isFinished() then
            call BJDebugMsg("Terrain still saving")
            call saveInstance.terrain.saveNextTiles()
            
        endif
    
        if saveInstance.unit.isFinished() and saveInstance.destructable.isFinished() and saveInstance.terrain.isFinished() then
            if User.fromLocal() == playerId then
                call BlzFrameSetVisible(saveProgressBar, false)
            endif
            call saveInstance.destroy()
        else
            call queue.append(playerId+1)
        endif
    endif
endfunction

function SaveStuff takes SaveInstance saveInstance, rect destRect, rect terrainRect returns nothing
    local SaveWriter saveWriter = saveInstance.saveWriter
    local PlayerData playerId = GetPlayerId(saveWriter.player)
    local boolean isSaving = false

    call BJDebugMsg(I2S(GetHandleId(saveInstance.unit.units)))
    call BJDebugMsg(I2S(saveInstance.unit.effects))
    call BJDebugMsg(I2S(BlzGroupGetSize(saveInstance.unit.units)))

    if not saveInstance.unit.isFinished() then
        call saveInstance.unit.initialize()
    endif
    if destRect != null then
        call saveInstance.destructable.initialize(ArrayListEnumDestructablesInRect(destRect))
    endif
    if terrainRect != null then
        call saveInstance.terrain.initialize(terrainRect)
    endif
    
    if not saveInstance.unit.isFinished() or not saveInstance.destructable.isFinished() or not saveInstance.terrain.isFinished() then
        if playerId.saveInstance != 0 then
            call LoP_WarnPlayer(saveWriter.player, LoPChannels.WARNING, "Did not finish saving previous file!")
            call playerId.saveInstance.destroy()
        else
            call PlayerData.playerQueue.append(playerId+1)
        endif
        set playerId.saveInstance = saveInstance
    
    else
        call LoP_WarnPlayer(saveWriter.player, LoPChannels.ERROR, "Nothing to save.")
        call saveInstance.destroy()
    endif
endfunction

function SaveUnits takes SaveInstance saveInstance returns nothing
    call SaveStuff(saveInstance, null, null)
endfunction

function SaveDestructables takes SaveInstance saveInstance, rect rectangle returns nothing
    call SaveStuff(saveInstance, rectangle, null)
endfunction

function SaveTerrain takes SaveInstance saveInstance, rect saveRect returns nothing
    call SaveStuff(saveInstance, null, saveRect)
endfunction

private struct InitStruct
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.5, true, function SaveLoopActions)
        set PlayerData.playerQueue = LinkedHashSet.create()
    endmethod
endstruct

endlibrary