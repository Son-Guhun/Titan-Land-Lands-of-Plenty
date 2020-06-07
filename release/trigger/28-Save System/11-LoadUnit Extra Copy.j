function ParseAbilityString takes unit whichUnit, string whichStr returns nothing
    local integer cutToComma
    local integer abilCode
    local integer count = 0
    local LinkedHashSet defaultAbils = UnitEnumRemoveableAbilityIds(whichUnit)
    
    call LoPCommandsAbility_ClearAbilities(whichUnit)
    
    loop
        set cutToComma = CutToComma(whichStr)
        exitwhen cutToComma >= StringLength(whichStr) or count >= 7
        
        set abilCode = S2ID(SubString(whichStr, 0, cutToComma))
        
        if IsAbilityAddable(abilCode) or defaultAbils.contains(abilCode) then
            call UnitAddAbility(whichUnit, abilCode)
        endif
    
        set count = count + 1
        set whichStr = SubString(whichStr, cutToComma + 1, StringLength(whichStr))
    endloop

    call defaultAbils.destroy()
endfunction

static if LIBRARY_UserDefinedRects then
    function Load_RestoreGUDR takes unit generator, string restoreStr returns nothing
        local integer splitterIndex
        
        local real length
        local real height
        local integer weatherType
        
        local TerrainFog fog
        local DNC dnc
        
        //Str = "length=height=weather= (we need an equal at the end in order to make future versions backwards-compatible
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set length = S2R(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set height = S2R(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set weatherType = S2I(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        call CreateGUDR(generator)
        call MoveGUDR(generator, length, height, false)
        call ChangeGUDRWeatherNew(generator, 0, weatherType)
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        if SubString(restoreStr,0,splitterIndex) != "0" then
            call ToggleGUDRVisibility(generator, false, true)
        else
            call ToggleGUDRVisibility(generator, false, false)
        endif
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        if splitterIndex != 0 and splitterIndex < StringLength(restoreStr) then
            set fog = RectEnvironment.get(GUDR_GetGeneratorRect(generator)).fog
            set dnc = RectEnvironment.get(GUDR_GetGeneratorRect(generator)).dnc

            set fog.style = S2I(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.zStart = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.zEnd = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.density = S2R(SubString(restoreStr,0,splitterIndex))/10000.
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.red = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.green = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.blue = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            if splitterIndex < StringLength(restoreStr)-1 then
                set dnc.lightTerrain = S2I(SubString(restoreStr,0,splitterIndex))
                set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
                
                set splitterIndex = CutToCharacter(restoreStr, "=")
                set dnc.lightUnit = S2I(SubString(restoreStr,0,splitterIndex))
                set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            endif
            
            call AutoRectEnvironment_RegisterRect(GUDR_GetGeneratorRect(generator))
        endif
    endfunction
endif

static if LIBRARY_MultiPatrol then
    function Load_RestorePatrolPoints takes unit whichUnit, SaveLoader saveData, string chatStr returns nothing
        local integer cutToComma = CutToCharacter(chatStr, "=")
        local real x = S2R(CutToCommaResult(chatStr, cutToComma)) - saveData.originalCenterX + saveData.centerX
        local real y
        
        set chatStr = CutToCommaShorten(chatStr, cutToComma)
        set cutToComma = CutToCharacter(chatStr, "=") 
        set y = S2R(CutToCommaResult(chatStr, cutToComma)) - saveData.originalCenterY + saveData.centerY
        
        // TODO: Create function to set first patrol in the GPS library
        if not Patrol_UnitHasPatrolPoints(whichUnit) then
            call SetUnitPosition(whichUnit, x, y)
            call Patrol_SetCurrentPatrolPoint(GetHandleId(whichUnit), 1)
        else
            call Patrol_RegisterPoint(whichUnit, x, y)
        endif
        
    endfunction
endif

function Load_RestoreWaygate takes string ha, SaveLoader saveData, unit whichGate returns nothing
    local integer cutToComma = CutToCharacter(ha, "=")
    local real x = S2R(CutToCommaResult(ha, cutToComma)) - saveData.originalCenterX
    local real y
    local string activate

    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set y = S2R(CutToCommaResult(ha, cutToComma)) - saveData.originalCenterY
    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set activate = CutToCommaResult(ha, cutToComma)
    
    if RAbsBJ(x) < saveData.extentX and RAbsBJ(y) < saveData.extentY then
        set x = x + saveData.centerX
        set y = y + saveData.centerY
    else
        set x = x + saveData.originalCenterX
        set y = y + saveData.originalCenterY
    endif
    
    call WaygateSetDestination(whichGate, x, y)
    if activate == "T" then
        call WaygateActivate(whichGate, true)
    else
        call WaygateActivate(whichGate, false)
    endif
endfunction

function Trig_LoadUnitNew_Extra_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string eventStr = BlzGetTriggerSyncData()// GetEventPlayerChatString()
    local string cmdStr = SubString(eventStr, 0, 3)
    
    if udg_save_LastLoadedUnit[playerId] == null then
        return
    endif
    
    
    if     cmdStr == "=n " then
        call GUMSSetUnitName(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
    elseif cmdStr == "=w " then
        call Load_RestoreWaygate(SubString(eventStr, 3, StringLength(eventStr)), SaveIO_GetCurrentlyLoadingSave(GetTriggerPlayer()), udg_save_LastLoadedUnit[playerId])
    elseif cmdStr == "=p " then
        static if LIBRARY_MultiPatrol then
            call Load_RestorePatrolPoints(udg_save_LastLoadedUnit[playerId], SaveIO_GetCurrentlyLoadingSave(GetTriggerPlayer()), SubString(eventStr, 3, StringLength(eventStr)))
        endif
    elseif cmdStr == "=h " then
        static if LIBRARY_LoPHeroicUnit then
            if IsValidHeroicUnit(udg_save_LastLoadedUnit[playerId], GetTriggerPlayer()) then 
                
                if LoP_GetPlayerHeroicUnitCount(GetOwningPlayer(udg_save_LastLoadedUnit[playerId])) >= 12 and GetTriggerPlayer() != udg_GAME_MASTER then
                    call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "Heroic unit limit reached for player. Only the Titan can make heroic units over this limit.")
                else
                    if GetTriggerPlayer() != udg_GAME_MASTER then
                        call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Player " + GetPlayerName(GetTriggerPlayer()) + " loaded a custom hero.")
                    endif
                    
                    call LoP_UnitMakeHeroic(udg_save_LastLoadedUnit[playerId])
                endif
                
                call RefreshHeroIcons(GetOwningPlayer(udg_save_LastLoadedUnit[playerId]))
            endif
        endif
    elseif cmdStr == "=a " then
        static if LIBRARY_CustomizableAbilityList then
            if GetUnitAbilityLevel(udg_save_LastLoadedUnit[playerId], 'AHer') > 0 then
                call ParseAbilityString(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
            endif
        endif
    else
        static if LIBRARY_UserDefinedRects then
            call Load_RestoreGUDR(udg_save_LastLoadedUnit[playerId], eventStr)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit_Extra_Copy takes nothing returns nothing
    set gg_trg_LoadUnit_Extra_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadUnit_Extra_Copy, function Trig_LoadUnitNew_Extra_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadUnit_Extra_Copy, "SnL_unit_extra", false)
endfunction

