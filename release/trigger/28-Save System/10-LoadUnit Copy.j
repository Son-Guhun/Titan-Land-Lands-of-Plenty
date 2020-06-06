function Trig_LoadUnitNew_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())+1
    local SaveNLoad_PlayerData playerId = playerNumber - 1
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = ( udg_load_number[playerNumber] + 1 )
        if saveData.atOriginal then
            if saveData.version < 5 then
                call LoadUnit(BlzGetTriggerSyncData(), GetTriggerPlayer(), saveData.centerX + playerId.centerX, saveData.centerY + playerId.centerY)
            else
                call LoadUnit(BlzGetTriggerSyncData(), GetTriggerPlayer(), playerId.centerX, playerId.centerY)
            endif
        else
            if saveData.version < 5 then
                call LoadUnit(BlzGetTriggerSyncData(), GetTriggerPlayer(), saveData.centerX, saveData.centerY)
            else
                call LoadUnit(BlzGetTriggerSyncData(), GetTriggerPlayer(), saveData.centerX - saveData.originalCenterX, saveData.centerY - saveData.originalCenterY)
            endif
        endif
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit_Copy takes nothing returns nothing
    set gg_trg_LoadUnit_Copy = CreateTrigger(  )
    //call DisableTrigger( gg_trg_LoadUnit_Copy )
    call TriggerAddAction( gg_trg_LoadUnit_Copy, function Trig_LoadUnitNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadUnit_Copy, "SnL_unit", false)
    
    // Cosmosis and Angel of Creation
    call SaveNLoad_ForbidUnitType('H00V')
    call SaveNLoad_ForbidUnitType('H00S')
    
    // Item Vaults
    call SaveNLoad_ForbidUnitType('nmgv')
    call SaveNLoad_ForbidUnitType('n02W')
    call SaveNLoad_ForbidUnitType('n02V')
    call SaveNLoad_ForbidUnitType('n02X')
endfunction

