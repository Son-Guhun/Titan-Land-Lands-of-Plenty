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

static if LIBRARY_MultiPatrol then
    function Load_RestorePatrolPoints takes unit whichUnit, string chatStr returns nothing
        local integer cutToComma = CutToCharacter(chatStr, "=")
        local real x = S2R(CutToCommaResult(chatStr, cutToComma))
        local real y
        
        set chatStr = CutToCommaShorten(chatStr, cutToComma)
        set cutToComma = CutToCharacter(chatStr, "=")
        set y = S2R(CutToCommaResult(chatStr, cutToComma))
        
        
        // TODO: Create function to set first patrol in the GPS library
        if not Patrol_UnitHasPatrolPoints(whichUnit) then
            call SetUnitPosition(whichUnit, x, y)
            call Patrol_SetCurrentPatrolPoint(GetHandleId(whichUnit), 1)
        else
            call Patrol_RegisterPoint(whichUnit, x, y)
        endif
        
    endfunction
endif

function Load_RestoreWaygate takes string ha, unit whichGate returns nothing
    local integer cutToComma = CutToCharacter(ha, "=")
    local real wayGateX = S2R(CutToCommaResult(ha, cutToComma))
    local real wayGateY
    local string activate

    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set wayGateY = S2R(CutToCommaResult(ha, cutToComma))
    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set activate = CutToCommaResult(ha, cutToComma)
    
    call WaygateSetDestination(whichGate, wayGateX, wayGateY)
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
        call Load_RestoreWaygate(SubString(eventStr, 3, StringLength(eventStr)), udg_save_LastLoadedUnit[playerId])
    elseif cmdStr == "=p " then
        static if LIBRARY_MultiPatrol then
            call Load_RestorePatrolPoints(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
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

