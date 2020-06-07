globals
    // These variables are used by the load triggers for the load limit.
    integer array stringsLoaded
    integer loadLimit  = 2147483647
endglobals

function Trig_LoadUnitNew_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())+1
    local SaveNLoad_PlayerData playerId = playerNumber - 1
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(Player(playerId))
    
    if stringsLoaded[playerNumber] < loadLimit then
        set stringsLoaded[playerNumber] = ( stringsLoaded[playerNumber] + 1 )
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
function InitTrig_LoadUnit takes nothing returns nothing
    set gg_trg_LoadUnit = CreateTrigger(  )
    //call DisableTrigger( gg_trg_LoadUnit )
    call TriggerAddAction( gg_trg_LoadUnit, function Trig_LoadUnitNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadUnit, "SnL_unit", false)
    
    // Cosmosis and Angel of Creation
    call SaveNLoad_ForbidUnitType('H00V')
    call SaveNLoad_ForbidUnitType('H00S')
    
    // Item Vaults
    call SaveNLoad_ForbidUnitType('nmgv')
    call SaveNLoad_ForbidUnitType('n02W')
    call SaveNLoad_ForbidUnitType('n02V')
    call SaveNLoad_ForbidUnitType('n02X')
endfunction

