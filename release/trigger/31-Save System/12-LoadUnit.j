function Trig_LoadUnit_Conditions takes nothing returns boolean
    // Can't load Cosmosis or Angel of Creation
    return udg_save_LoadUnitType != 'H00V' and udg_save_LoadUnitType != 'H00S'
endfunction

function Trig_LoadUnit_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local integer playerNumber = playerId+1
    if Save_IsPlayerLoading(playerId) then
        if udg_load_number[playerNumber] < udg_load_limit then
            set udg_load_number[playerNumber] = ( udg_load_number[playerNumber] + 1 )
            call LoadUnit(GetEventPlayerChatString(),GetTriggerPlayer())
        endif
    else
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit takes nothing returns nothing
    set gg_trg_LoadUnit = CreateTrigger(  )
    call DisableTrigger( gg_trg_LoadUnit )
    call TriggerAddCondition( gg_trg_LoadUnit, Condition( function Trig_LoadUnit_Conditions ) )
    call TriggerAddAction( gg_trg_LoadUnit, function Trig_LoadUnit_Actions )
endfunction

