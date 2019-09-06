function Trig_CommandsR_Mind_Filter takes nothing returns nothing
    call IssueTargetOrder(POWER_MIND(), "smart" , GetFilterUnit())
endfunction

function Trig_CommandsR_Mind_Conditions takes nothing returns boolean
    local string command = LoP_Command.getCommand()
    local string args = LoP_Command.getArguments()
    local player oldPlayer = udg_PowerSystem_Player
    
    local integer playerNumber
    if ( command == "'mind" ) then
        if args != "" then
            set playerNumber = Commands_GetChatMessagePlayerNumber(args)
            if  PlayerNumberIsNotExtraOrVictim(playerNumber) then
                set udg_PowerSystem_Player = Player(playerNumber-1)
            endif
        endif
        
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Filter(function Trig_CommandsR_Mind_Filter))
        set udg_PowerSystem_Player = oldPlayer
    elseif ( command == "-mind" ) then
        if args == "" then
            if ( udg_PowerSystem_allFlag ) then
                call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "Flagged Mind power to change ownership of target unit ONLY" )
                set udg_PowerSystem_allFlag = false
            else
                call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "Flagged Mind power to change ownership of ALL units owned by owner of target unit." )
                set udg_PowerSystem_allFlag = true
            endif
        else
            set playerNumber = Commands_GetChatMessagePlayerNumber(args)
            if  PlayerNumberIsNotExtraOrVictim(playerNumber) then
                set udg_PowerSystem_Player = Player(playerNumber-1)
                call SetUnitColor( POWER_MIND(), GetPlayerColor(udg_PowerSystem_Player) )
            endif
        endif
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Mind takes nothing returns nothing
    call LoP_Command.create("-mind", ACCESS_TITAN, Condition(function Trig_CommandsR_Mind_Conditions))
    call LoP_Command.create("'mind", ACCESS_TITAN, Condition(function Trig_CommandsR_Mind_Conditions))
endfunction

