library RectSaveLoader initializer Init requires SaveIO

globals
    private string array nextSave
endglobals

private struct UnitData extends array
    //! runtextmacro TableStruct_NewStructField("saveData", "SaveLoader")
    
    method destroy takes nothing returns nothing
        if .saveDataExists() then
            call .saveDataClear()
        endif
    endmethod
    
    static method get takes unit whichUnit returns thistype
        return GetHandleId(whichUnit)
    endmethod
endstruct

function ClearSaveLoaderData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).destroy()
endfunction

public function onReceiveSize takes nothing returns nothing
    local unit generator
    local string syncData = BlzGetTriggerSyncData()
    local SaveLoader saveData
    
    if syncData == "end" then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "Finished loading!")
        set saveData = SaveIO_GetCurrentlyLoadingSave(GetTriggerPlayer())
        call saveData.destroy()
        return
    elseif SubString(syncData, 0, 2) == "p=" then
        set nextSave[GetPlayerId(GetTriggerPlayer())] = SubString(syncData, 2, StringLength(syncData))
        return
    endif
    
    set saveData = SaveLoader.create(GetTriggerPlayer(), nextSave[GetPlayerId(GetTriggerPlayer())], syncData)
    
    if not saveData.atOriginal then
        set generator = CreateUnit(GetTriggerPlayer(), RectGenerator_GENERATOR_ID, saveData.centerX, saveData.centerY, 270.)
    
        call UnitRemoveAbility(generator, RectGenerator_CREATE_OR_DESTROY)
        call UnitRemoveAbility(generator, RectGenerator_TOGGLE_VISIBILITY)
        call UnitRemoveAbility(generator, RectGenerator_PAGE_NEXT)
        call UnitRemoveAbility(generator, RectGenerator_PAGE_PREV)
        
        call UnitRemoveAbility(generator, RectGenerator_RETRACT_X)
        call UnitRemoveAbility(generator, RectGenerator_EXPAND_X)
        call UnitRemoveAbility(generator, RectGenerator_RETRACT_Y)
        call UnitRemoveAbility(generator, RectGenerator_EXPAND_Y)
        
        call UnitRemoveAbility(generator, RectGenerator_LOCK_UNITS)
        call UnitRemoveAbility(generator, RectGenerator_UNLOCK_UNITS)
        
        call UnitAddAbility(generator, 'A061')
        call UnitAddAbility(generator, 'A062')
        
        set UnitData.get(generator).saveData = saveData
        call CreateGUDR(generator)
        call MoveGUDR(generator, saveData.extentX, saveData.extentY, false)
        
        if GetLocalPlayer() == GetTriggerPlayer() then
            call ClearSelection()
            call SelectUnit(generator, true)
            call SetCameraPosition(GetUnitX(generator), GetUnitY(generator))
        endif
    else
        call saveData.loadData()
    endif
endfunction

function TriggerRegisterAnyPlayerSyncEvent takes trigger whichTrigger, string prefix, boolean fromServer returns nothing
    local integer i = 0
    local player slot
    
    loop
    exitwhen i == bj_MAX_PLAYERS
        set slot = Player(i)
        if GetPlayerController(slot) == MAP_CONTROL_USER then
            call BlzTriggerRegisterPlayerSyncEvent(whichTrigger, slot, prefix, fromServer)
        endif
        
        set i = i + 1
    endloop
endfunction

private function onAbility takes nothing returns nothing
    local SaveLoader saveData
    local unit trigU
    if GetSpellAbilityId() == 'A061' then
        set trigU = GetTriggerUnit()
        set saveData = UnitData.get(trigU).saveData
        set UnitData.get(trigU).saveData = 0  // Remove data so it is not destroyed when the unit is removed from the game
        
        set saveData.centerX = GetUnitX(trigU)
        set saveData.centerY = GetUnitY(trigU)
        call saveData.loadData()
        call KillUnit(trigU)
        
        set trigU = null
    elseif GetSpellAbilityId() == 'A062' then
        set trigU = GetTriggerUnit()
        set saveData = UnitData.get(trigU).saveData
        
        call SetUnitPosition(trigU, saveData.centerX, saveData.centerY)
        call MoveGUDR(trigU, 0, 0, true)
    endif
    
    set trigU = null
endfunction

private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    
    call TriggerAddAction(t, function onReceiveSize)
    call TriggerRegisterAnyPlayerSyncEvent(t, "SnL_IOsize", false)
    
    set t = CreateTrigger()
    call TriggerAddAction(t, function onAbility)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
endfunction

endlibrary