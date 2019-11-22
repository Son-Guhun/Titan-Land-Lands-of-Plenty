
function Trig_SaveLoad_Commands_Actions takes nothing returns nothing
    local group udg_temp_group
    local unit udg_temp_unit
    local location udg_temp_point
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    if ( GetEventPlayerChatString() == "-load center" ) then
        set udg_temp_group = CreateGroup()
        
        call GroupEnumUnitsSelected(udg_temp_group, GetTriggerPlayer(), null)
        set udg_temp_unit = FirstOfGroup(udg_temp_group)
        if IsUnitType(udg_temp_unit, UNIT_TYPE_STRUCTURE) then
            set udg_temp_point = GetUnitRallyPoint(udg_temp_unit)
            if udg_temp_point == null then
                set udg_temp_point = GetUnitLoc(GetUnitRallyUnit(udg_temp_unit))
            endif
        else
            set udg_temp_point = GetUnitLoc(udg_temp_unit)
        endif
        
        set playerId.centerX = GetLocationX(udg_temp_point)
        set playerId.centerY = GetLocationY(udg_temp_point)
        
        call RemoveLocation (udg_temp_point)
        call DestroyGroup (udg_temp_group)
        set udg_temp_group = null
        set udg_temp_unit = null
        set udg_temp_point = null
    else
        // SET LOAD LIMIT COMMAND
        if ( GetTriggerPlayer() == udg_GAME_MASTER ) then
            set udg_load_limit = S2I(SubStringBJ(GetEventPlayerChatString(), 13, StringLength(GetEventPlayerChatString())))
            call DisplayTextToForce( GetPlayersAll(), ( "Unit Load Limit has been set to " + I2S(udg_load_limit) ) )
            // Double conversion ensures that, if for some reason the first conversion did not work out, the players won't receive the correct message
        else
        endif
    endif
endfunction

//===========================================================================
function InitTrig_SaveLoad_Commands takes nothing returns nothing
    set gg_trg_SaveLoad_Commands = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveLoad_Commands, function Trig_SaveLoad_Commands_Actions )
endfunction

