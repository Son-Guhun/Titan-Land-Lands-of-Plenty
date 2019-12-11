function Trig_LoadUnit_Conditions takes nothing returns boolean
    // Can't load Cosmosis or Angel of Creation
    return udg_save_LoadUnitType != 'H00V' and udg_save_LoadUnitType != 'H00S'
endfunction


function Trig_LoadUnitNew_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())+1
    local SaveNLoad_PlayerData playerId = playerNumber - 1
    
    if udg_load_number[playerNumber] < udg_load_limit then
        set udg_load_number[playerNumber] = ( udg_load_number[playerNumber] + 1 )
        call LoadUnit(BlzGetTriggerSyncData()/*GetEventPlayerChatString()*/,GetTriggerPlayer(), playerId.centerX, playerId.centerY)
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit_Copy takes nothing returns nothing
    set gg_trg_LoadUnit_Copy = CreateTrigger(  )
    //call DisableTrigger( gg_trg_LoadUnit_Copy )
    call TriggerAddAction( gg_trg_LoadUnit_Copy, function Trig_LoadUnitNew_Actions )
    call TriggerRegisterAnyPlayerSyncEvent( gg_trg_LoadUnit_Copy, "SnL_unit", false)
endfunction

