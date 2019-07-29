function Trig_LoadUnitNew_Extra_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string eventStr = BlzGetTriggerSyncData()// GetEventPlayerChatString()
    local string cmdStr = SubStringBJ(eventStr, 1, 3)
    
    if     cmdStr == "=n " then
        call GUMSSetUnitName(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
    elseif cmdStr == "=w " then
        call Load_RestoreWaygate(SubString(eventStr, 3, StringLength(eventStr)), udg_save_LastLoadedUnit[playerId])
    elseif cmdStr == "=p " then
        static if LIBRARY_MultiPatrol then
            call Load_RestorePatrolPoints(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
        endif
    elseif cmdStr == "=h " then
        call BJDebugMsg("Heroic Unit")
        static if LIBRARY_LoPHeroicUnit then
            if IsValidHeroicUnit(udg_save_LastLoadedUnit[playerId], GetTriggerPlayer()) then 
                
                call BJDebugMsg("0")
                if LoP_GetPlayerHeroicUnitCount(GetOwningPlayer(udg_save_LastLoadedUnit[playerId])) >= 12 and GetTriggerPlayer() != udg_GAME_MASTER then
                    call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "Heroic unit limit reached for player. Only the Titan can make heroic units over this limit.")
                else
                    call BJDebugMsg("1")
                    if GetTriggerPlayer() != udg_GAME_MASTER then
                        call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Player " + GetPlayerName(GetTriggerPlayer()) + " loaded a custom hero.")
                    endif
                    
                    call BJDebugMsg("2")
                    call LoP_UnitMakeHeroic(udg_save_LastLoadedUnit[playerId])
                endif
                
                call RefreshHeroIcons(GetOwningPlayer(udg_save_LastLoadedUnit[playerId]))
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

