function MissingDecos_HelpMessage takes nothing returns string

    return "
Hey there! In LoP, there are a total of |c00ffff00" + I2S(udg_System_DecoTotal) + "|r Deco Builders.

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
        if LoadInteger(udg_Hashtable_2, playerNumber, udg_DecoUnitTypes[firstIndex] ) == 0 then
            call CreateUnitAtLoc( whichPlayer, udg_DecoUnitTypes[firstIndex], udg_PLAYER_LOCATIONS[playerNumber], bj_UNIT_FACING )
        endif
        set firstIndex = firstIndex + 1
    endloop
endfunction

function Trig_Commands_Deco_Spawn_Actions takes nothing returns nothing
    local string arg = Commands_GetArguments()
    local integer lastIndex

    if arg == " special" then
        set lastIndex = LoP_DecoBuilders.SpecialDecoLastIndex
        
    elseif arg == " basic" then
        set lastIndex = LoP_DecoBuilders.BasicDecoLastIndex
        
    elseif arg == " advanced" or arg == " adv" or arg == " all" then
        set lastIndex = LoP_DecoBuilders.AdvDecoLastIndex
        
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, MissingDecos_HelpMessage())
        return
    endif

    call Commands_CreateMissingDecos(GetTriggerPlayer(), 0, lastIndex)
endfunction

//===========================================================================
function InitTrig_Commands_Spawn_Decos takes nothing returns nothing
    set gg_trg_Commands_Spawn_Decos = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Spawn_Decos, function Trig_Commands_Deco_Spawn_Actions )
endfunction

