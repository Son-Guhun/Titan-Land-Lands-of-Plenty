function Trig_CommandsR_Delete_Func018A takes nothing returns nothing
    if RectContainsUnit(gg_rct_Titan_Palace, GetEnumUnit()) == commandsDeleteInsideTitanPalace and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetEnumUnit())
    endif
endfunction

function Trig_CommandsR_Delete_Conditions takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
    // --------------
    // DON'T ALLOW DELETION OF THE OWNER OF THE GDS DUMMIES
    if not PlayerNumberIsNotExtraOrVictim(playerNumber) or  GetTriggerPlayer() != udg_GAME_MASTER then
        return false
    endif
    
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 500
    if ( GetEventPlayerChatStringMatched() == "-delneu " ) then
        set commandsDeleteInsideTitanPalace = false
        call ForGroup( udg_System_NeutralUnits[( playerNumber - 1 )], function Trig_CommandsR_Delete_Func018A )
        // Don't clear neutral group, protected units might be in it. Let automatic refresh take care of this.
    elseif ( GetEventPlayerChatStringMatched() == "-delpal " ) then
        set commandsDeleteInsideTitanPalace = true
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
        call ForGroup( udg_System_NeutralUnits[( playerNumber - 1 )], function Trig_CommandsR_Delete_Func018A )
    else
        set commandsDeleteInsideTitanPalace = false
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(playerNumber - 1), Condition(function GroupEnum_RemoveOutsidePalace))
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Delete takes nothing returns nothing
    set gg_trg_CommandsR_Delete = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_CommandsR_Delete, Condition( function Trig_CommandsR_Delete_Conditions ) )
endfunction

