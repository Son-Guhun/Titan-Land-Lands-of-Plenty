library SaveUtils

    struct SaveInstanceBase
        SaveData saveWriter
    endstruct
    
    module SaveInstanceBaseModule
        
        method operator saveWriter takes nothing returns SaveData
            return SaveInstanceBase(this).saveWriter
        endmethod
        
    endmodule


endlibrary

library SaveMain requires TileDefinition, SaveIO, SaveUnit, SaveUtils


struct SaveInstance//  extends array


    implement SaveInstanceBaseModule
    
    
    static method create takes SaveData saveWriter returns thistype
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
    local SaveData saveWriter = saveInstance.saveWriter
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