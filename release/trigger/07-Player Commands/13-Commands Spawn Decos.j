function MissingDecos_HelpMessage1 takes nothing returns string
    return"Hey there! In LoP, there are a total of |c00ffff00" + I2S(LoP_DecoBuilders.DecoLastIndex+LoP_DecoBuilders.ReforgedDecoLastIndex-LoP_DecoBuilders.SpecialDecoLastIndex+1) + "|r Deco Builders.

This can make it quite hard for newer players to decide what to build and get going. It is recommended, if you have never played the game before, to go with only the basic deco builders. Please supply arguments to this command:

    |c00ffff00-decos special|r => Spawns only the special deco builders.
    
    Reforged models ("+I2S(LoP_DecoBuilders.ReforgedDecoLastIndex-LoP_DecoBuilders.SpecialDecoLastIndex+1)+" builders):"
endfunction

function MissingDecos_HelpMessage2 takes nothing returns string

    return "        |c00ffff00-decos reforged|r => Spawns deco builders which contain Reforged models (Reforged graphics only)

    Classic models ("+I2S(LoP_DecoBuilders.DecoLastIndex-LoP_DecoBuilders.SpecialDecoLastIndex+1)+" builders):
        |c00ffff00-decos basic|r => Spawns special decos and basic decos |c00ffff00(for new players)|r

        |c00ffff00-decos all|r => Spawns ALL deco builders |c00ffff00(for recurring players)|r"


endfunction

function Trig_Commands_Deco_Spawn_Conditions takes nothing returns boolean
    local string arg = LoP_Command.getArguments()
    local integer lastIndex
    local LoP_PlayerData pId = LoP_PlayerData.get(GetTriggerPlayer())

    if arg == "special" then
        call LoPDecoBuilders_CreateMissing(pId.handle, pId.locX, pId.locY, null, 0, LoP_DecoBuilders.SpecialDecoLastIndex, DECO_BUILDERS_CLASSIC)
    elseif arg == "basic" then
        call LoPDecoBuilders_CreateMissing(pId.handle, pId.locX, pId.locY, null, 0, LoP_DecoBuilders.BasicDecoLastIndex, DECO_BUILDERS_CLASSIC)
    elseif arg == "advanced" or arg == "adv" or arg == "all" then
        call LoPDecoBuilders_CreateMissing(pId.handle, pId.locX, pId.locY, null, 0, LoP_DecoBuilders.AdvDecoLastIndex, DECO_BUILDERS_CLASSIC)
    elseif arg == "reforged" then
        call LoPDecoBuilders_CreateMissing(pId.handle, pId.locX, pId.locY, null, 0,  LoP_DecoBuilders.ReforgedDecoLastIndex, DECO_BUILDERS_REFORGED)
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, MissingDecos_HelpMessage1())
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, MissingDecos_HelpMessage2())
        return false
    endif

    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Spawn_Decos takes nothing returns nothing
    call LoP_Command.create("-decos", ACCESS_USER, Condition(function Trig_Commands_Deco_Spawn_Conditions ))
endfunction

