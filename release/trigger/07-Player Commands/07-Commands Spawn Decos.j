function MissingDecos_HelpMessage takes nothing returns string

    return "
Hey there! In LoP, there are a total of |c00ffff00" + I2S(LoP_DecoBuilders.DecoLastIndex+1) + "|r Deco Builders.

This can make it quite hard for newer players to decide what to build and get going. It is recommended, if you have never played the game before, to go with only the basic deco builders. Please supply arguments to this command:

    |c00ffff00-decos special|r => Spawns only the special deco builders.

    |c00ffff00-decos basic|r => Spawns special decos and basic decos |c00ffff00(for new players)|r

    |c00ffff00-decos all|r => Spawns ALL deco builders |c00ffff00(for recurring players)|r
    "


endfunction


//Checks the deco counter for the player. If any counter is 0, create the missing deco.
function Commands_CreateMissingDecos takes player whichPlayer, integer firstIndex, integer lastIndex returns nothing
    local integer playerNumber = GetPlayerId( whichPlayer ) + 1

    loop
    exitwhen firstIndex > lastIndex
        if LoadInteger(udg_Hashtable_2, playerNumber, LoP_DecoBuilders.rawcodes[firstIndex] ) == 0 then
            call CreateUnitAtLoc( whichPlayer, LoP_DecoBuilders.rawcodes[firstIndex], udg_PLAYER_LOCATIONS[playerNumber], bj_UNIT_FACING )
        endif
        set firstIndex = firstIndex + 1
    endloop
endfunction

function Trig_Commands_Deco_Spawn_Conditions takes nothing returns boolean
    local string arg = LoP_Command.getArguments()
    local integer lastIndex

    if arg == "special" then
        set lastIndex = LoP_DecoBuilders.SpecialDecoLastIndex
        
    elseif arg == "basic" then
        set lastIndex = LoP_DecoBuilders.BasicDecoLastIndex
        
    elseif arg == "advanced" or arg == "adv" or arg == "all" then
        set lastIndex = LoP_DecoBuilders.AdvDecoLastIndex
        
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, MissingDecos_HelpMessage())
        return false
    endif

    call Commands_CreateMissingDecos(GetTriggerPlayer(), 0, lastIndex)
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Spawn_Decos takes nothing returns nothing
    call LoP_Command.create("-decos", ACCESS_USER, Condition(function Trig_Commands_Deco_Spawn_Conditions ))
endfunction

