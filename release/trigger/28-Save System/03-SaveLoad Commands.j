
function Trig_SaveLoad_Commands_Actions takes nothing returns nothing
    local group g
    local unit u
    local location loc
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    if ( GetEventPlayerChatString() == "-load center" ) then
        set g = CreateGroup()
        
        call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
        set u = FirstOfGroup(g)
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set loc = GetUnitRallyPoint(u)
            if loc == null then
                set loc = GetUnitLoc(GetUnitRallyUnit(u))
            endif
        else
            set loc = GetUnitLoc(u)
        endif
        
        set playerId.centerX = GetLocationX(loc)
        set playerId.centerY = GetLocationY(loc)
        call DisplayTextToPlayer( GetTriggerPlayer(), 0, 0, "Save/Load Center set to: (" + R2S(playerId.centerX) + " | " + R2S(playerId.centerY) + ")")
        
        call RemoveLocation (loc)
        call DestroyGroup (g)
        set g = null
        set u = null
        set loc = null
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

