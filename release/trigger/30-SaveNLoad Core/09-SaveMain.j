library SaveMain requires SaveIO, SaveUnit, SaveDestructable, SaveTerrain, LoPWarn
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
        
        if .unit.hasUnits() then
            call DestroyGroup(.unit.units)
        endif
        if .unit.hasEffects() then
            call .unit.effects.destroy()
        endif
        if .destructable.isInitialized() then
            call .destructable.destructables.destroy()
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
        set playerId = queue.getFirst() - 1
        set saveInstance = playerId.saveInstance
        
        call queue.remove(playerId+1)
        
        if not saveInstance.unit.isFinished() then
            call saveInstance.unit.saveNextUnits()
            
        elseif not saveInstance.destructable.isFinished() then
            call saveInstance.destructable.saveNextDestructables()
            
        elseif not saveInstance.terrain.isFinished() then
            call saveInstance.terrain.saveNextTiles()
            
        endif
    
        if saveInstance.unit.isFinished() and saveInstance.destructable.isFinished() and saveInstance.terrain.isFinished() then
            if User.fromLocal() == playerId then
                call BlzFrameSetVisible(saveProgressBar, false)
            endif
            set playerId.saveInstance = 0
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