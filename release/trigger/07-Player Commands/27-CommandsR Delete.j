function Trig_CommandsR_Delete_Func018A takes nothing returns nothing
    if RectContainsUnit(gg_rct_Titan_Palace, GetEnumUnit()) == commandsDeleteInsideTitanPalace and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetEnumUnit())
    endif
endfunction

function Trig_CommandsR_Delete_Conditions takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local string command = LoP_Command.getCommand()
    local LinkedHashSet_DecorationEffect test 
    local DecorationEffect i
    
    // --------------
    // DON'T ALLOW DELETION OF THE OWNER OF THE GDS DUMMIES
    if not PlayerNumberIsNotExtraOrVictim(playerNumber) then
        return false
    endif
    
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 500
    if ( command == "-delneu" ) then
        set commandsDeleteInsideTitanPalace = false
        call ForGroup( udg_System_NeutralUnits[( playerNumber - 1 )], function Trig_CommandsR_Delete_Func018A )
        // Don't clear neutral group, protected units might be in it. Let automatic refresh take care of this.
    elseif ( command == "-delpal" ) then
        set commandsDeleteInsideTitanPalace = true
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
        call ForGroup( udg_System_NeutralUnits[( playerNumber - 1 )], function Trig_CommandsR_Delete_Func018A )
    else
        set test = EnumDecorationsOfPlayer(Player(0))
        set i = test.begin()
    
        set commandsDeleteInsideTitanPalace = false
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
        
        loop
        exitwhen i == test.end()
            call i.destroy()
            set i = test.next(i)
        endloop
        
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

