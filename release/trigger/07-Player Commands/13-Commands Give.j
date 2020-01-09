scope CommandsGive

private function GroupFilter takes nothing returns boolean
    // No need to check if the units are protected, since it's only enumerating units outside of the titan palace
    if not RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) then
        call SetUnitOwner( GetFilterUnit(), udg_PowerSystem_Player, false )
    endif
    return false
endfunction


private function MindPower takes unit target returns nothing
    local player owner = GetOwningPlayer(target)
    local LinkedHashSet_DecorationEffect decorations 
    local DecorationEffect i
    local integer color = GetHandleId(LoP_PlayerData.get(owner).getUnitColor())
    
    if udg_PowerSystem_allFlag then
            set decorations = EnumDecorationsOfPlayer(owner)
            set i = decorations.begin()
            
            loop
            exitwhen i == decorations.end()
                call i.setOwner(udg_PowerSystem_Player)
                set i = decorations.next(i)
            endloop
            call decorations.destroy()
    
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, owner, Condition(function GroupFilter))
            set udg_PowerSystem_allFlag = false
    else
        if not LoP_IsUnitProtected(target) or target == HERO_COSMOSIS() or target == HERO_CREATOR() then 
            call SetUnitOwner(target, udg_PowerSystem_Player, false)
        endif
    endif
endfunction

function Trig_Commands_Give_Func020A takes nothing returns nothing
    if GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() or GetTriggerPlayer() == udg_GAME_MASTER then
        if CheckCommandOverflow() then
            call MindPower(GetEnumUnit())
        endif
    else
        call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "This is not your unit." )
    endif
endfunction

function Trig_Commands_Give_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    local boolean storeAllFlag
    local integer playerNumber
    local player oldPlayer
    
    if SubString(LoP_Command.getArguments(), 0, 4) == "all " then
        set playerNumber = Commands_GetChatMessagePlayerNumber(SubString(LoP_Command.getArguments(), 4, StringLength(LoP_Command.getArguments())))
        set udg_PowerSystem_Player = ConvertedPlayer(playerNumber)
        set udg_PowerSystem_allFlag = true
    else
        set playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
        set udg_PowerSystem_Player = ConvertedPlayer(playerNumber)
        set udg_PowerSystem_allFlag = false
    endif
        
    if  PlayerNumberIsNotExtraOrVictim(playerNumber) then
        if  playerNumber != PLAYER_NEUTRAL_PASSIVE+1 then
            set oldPlayer = udg_PowerSystem_Player
            
            // ---------------------------------------------
            // PICK SELECTED UNITS AND CHECK FOR RECT GENERATOR
            call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
            
            
                
            if udg_PowerSystem_allFlag then
                if GetOwningPlayer(FirstOfGroup(g)) == GetTriggerPlayer() or GetTriggerPlayer() == udg_GAME_MASTER then
                    call MindPower(FirstOfGroup(g))
                    set udg_PowerSystem_Player = oldPlayer
                else
                    call DisplayTextToPlayer(GetTriggerPlayer(),0,0, "This is not your unit." )
                endif
            else
                set udg_Commands_Counter = 0
                set udg_Commands_Counter_Max = 1000
                call ForGroup( g, function Trig_Commands_Give_Func020A )
                set udg_PowerSystem_Player = oldPlayer
            endif
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

endscope