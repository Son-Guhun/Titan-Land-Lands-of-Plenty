function Trig_CommandsR_Delete_Func018A takes nothing returns nothing
    if RectContainsUnit(gg_rct_Titan_Palace, GetEnumUnit()) == commandsDeleteInsideTitanPalace and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetEnumUnit())
    endif
endfunction

function Trig_CommandsR_Delete_Conditions takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local string command = LoP_Command.getCommand()
    local player targetPlayer
    local LinkedHashSet_DecorationEffect test 
    local DecorationEffect i
    
    // --------------
    // DON'T ALLOW DELETION OF THE OWNER OF THE GDS DUMMIES
    if not PlayerNumberIsNotExtraOrVictim(playerNumber) then
        return false
    endif
    
    set targetPlayer = Player(playerNumber - 1)
    
    set udg_Commands_Counter = 0
    if ( command == "-delneu" ) then
    
        set commandsDeleteInsideTitanPalace = false
        set udg_Commands_Counter_Max = 500
        call LoP_ForNeutralUnits(targetPlayer, function Trig_CommandsR_Delete_Func018A )
        // Don't clear neutral group, protected units might be in it. Let automatic refresh take care of this.
    elseif ( command == "-delpal" ) then
    
        set commandsDeleteInsideTitanPalace = true
        set udg_Commands_Counter_Max = 500
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
        call LoP_ForNeutralUnits(targetPlayer, function Trig_CommandsR_Delete_Func018A )
    else
    
        set test = EnumDecorationsOfPlayer(Player(playerNumber - 1))
        set i = test.begin()
        
        set udg_Commands_Counter_Max = 1500
        loop
        exitwhen i == test.end() or not CheckCommandOverflow()
            call i.destroy()
            set i = test.next(i)
        endloop
    
        set udg_Commands_Counter = udg_Commands_Counter/3
        set udg_Commands_Counter_Max = 500
        if udg_Commands_Counter < 250 then  // not worth less than 250 executions
            set commandsDeleteInsideTitanPalace = false
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
        elseif udg_Commands_Counter < udg_Commands_Counter_Max then
            set udg_Commands_Counter = udg_Commands_Counter_Max
            call CheckCommandOverflow()
        endif
        
        call test.destroy()
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Delete takes nothing returns nothing
    call LoP_Command.create("-delete", ACCESS_TITAN, Condition(function Trig_CommandsR_Delete_Conditions))
    call LoP_Command.create("-delneu", ACCESS_TITAN, Condition(function Trig_CommandsR_Delete_Conditions))
    call LoP_Command.create("-delpal", ACCESS_TITAN, Condition(function Trig_CommandsR_Delete_Conditions))
endfunction

