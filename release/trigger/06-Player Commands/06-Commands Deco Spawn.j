function MissingDecos_HelpMessage takes nothing returns string

    return "Hey there! In LoP, there are a total of " + I2S(udg_System_DecoTotal) + "Deco Builders.
    This can make it quite hard for newer players to decide what to build and get going. It is recommended, if you have never played the game before, to go with only the basic deco builders. Please supply arguments to this command:

    -deco special => Spawns only the special deco builders (Terrain, Modifications, Misc and Docks)

    -deco basic => Spawns special decos and basic decos (recommended for new players)

    -deco all => Spawns ALL deco builders (only recommended for recurring players)
    "


endfunction


//Checks the deco counter for the player. If any counter is 0, create the missing deco.
function Commands_CreateMissingDecos takes player whichPlayer, integer firstIndex, integer lastIndex returns nothing
    local integer playerNumber = GetPlayerId( whichPlayer ) + 1

    loop
    exitwhen firstIndex > lastIndex
        if LoadInteger(udg_Hashtable_2, playerNumber, udg_DecoUnitTypes[i] ) == 0 then
            call CreateUnitAtLoc( whichPlayer, udg_DecoUnitTypes[i], udg_PLAYER_LOCATIONS[playerNumber], bj_UNIT_FACING )
        endif
        set firstIndex = firstIndex + 1
    endloop
endfunction

function Trig_Commands_Deco_Spawn_Actions takes nothing returns nothing
    local string arg = Commands_GetArguments()
    local integer lastIndex

    if arg == " special" then
        set lasIndex = LoP_DecoBuilders.SpecialDecoLastIndex
    elseif arg == " basic" then
        set lastIndex = LoP_DecoBuilders.BasicDecoLastIndex
    elseif arg == " advanced" or arg == " adv" or arg==" all" then
        set lastIndex = LoP_DecoBuilders.AdvDecoLastIndex
    else
        DisplayTextToPlayer(whichPlayer, 0, 0, MissingDeco_HelpMessage())
        return
    endif

    call Commands_CreateMissingDecos(GetTriggerPlayer(), 0, lastIndex)
endfunction

//===========================================================================
function InitTrig_Commands_Deco_Spawn takes nothing returns nothing
    set gg_trg_Commands_Deco_Spawn = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Deco_Spawn, function Trig_Commands_Deco_Spawn_Actions )
endfunction

