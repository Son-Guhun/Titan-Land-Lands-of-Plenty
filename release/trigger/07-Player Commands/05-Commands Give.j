function Trig_Commands_Give_Func020A takes nothing returns nothing
    if GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() or GetTriggerPlayer() == udg_GAME_MASTER then
        if CheckCommandOverflow() then
            call IssueTargetOrder(gg_unit_e00D_0409, "smart" , GetEnumUnit())
        endif
    else
        call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "This is not your unit." )
    endif
endfunction

function Trig_Commands_Give_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    local boolean storeAllFlag
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local player oldPlayer
    
    if  PlayerNumberIsNotExtraOrVictim(playerNumber) then
        if  playerNumber != PLAYER_NEUTRAL_PASSIVE+1 then
            set oldPlayer = udg_PowerSystem_Player
            set udg_PowerSystem_Player = ConvertedPlayer(playerNumber)
            // ---------------------------------------------
            // PICK SELECTED UNITS AND CHECK FOR RECT GENERATOR
            call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
            // ---------------------------------------------
            set storeAllFlag = udg_PowerSystem_allFlag
            set udg_PowerSystem_allFlag = false
            // ---------------------------------------------
            set udg_Commands_Counter = 0
            set udg_Commands_Counter_Max = 1000
            call ForGroup( g, function Trig_Commands_Give_Func020A )
            set udg_PowerSystem_Player = oldPlayer
            // ---------------------------------------------
            set udg_PowerSystem_allFlag = storeAllFlag
            // ---------------------------------------------
        else
            call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "DO NOT use |c00ffff00-give|r command to give units to neutral passive. Please use the |c00ffff00-neut|r command! You will be able to take your units back with |c00ffff00-take|r or |c00ffff00-take all|r." )
        endif
    endif
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Give takes nothing returns nothing
    call LoP_Command.create("-give", ACCESS_USER, Condition(function Trig_Commands_Give_Conditions ))
endfunction