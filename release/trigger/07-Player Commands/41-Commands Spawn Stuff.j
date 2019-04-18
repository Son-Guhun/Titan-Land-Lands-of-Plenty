/* This trigger defines the commands:
-rect => Spawns a rect generator
-start => Spawns a race selector
-controller => Spawns a Deco Modifier Controller
*/

function Trig_Commands_Spawn takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string command  = LoP_Command.getCommand()

    if ( command == "-rect" ) then
        call CreateUnitAtLoc(GetTriggerPlayer(), RectGenerator_GENERATOR_ID, udg_PLAYER_LOCATIONS[GetConvertedPlayerId(GetTriggerPlayer())], bj_UNIT_FACING )
    elseif ( command == "-start" ) then
        call CreateUnitAtLoc(GetTriggerPlayer(), 'e000', udg_PLAYER_LOCATIONS[GetConvertedPlayerId(GetTriggerPlayer())], bj_UNIT_FACING )
    elseif ( command == "-controller" ) then
        call CreateUnitAtLoc(GetTriggerPlayer(), 'h0KD', udg_PLAYER_LOCATIONS[GetConvertedPlayerId(GetTriggerPlayer())], bj_UNIT_FACING )
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Spawn_Stuff takes nothing returns nothing    
    call LoP_Command.create("-start", ACCESS_USER, Condition(function Trig_Commands_Spawn))
    call LoP_Command.create("-rect", ACCESS_USER, Condition(function Trig_Commands_Spawn))
    call LoP_Command.create("-controller", ACCESS_USER, Condition(function Trig_Commands_Spawn))
endfunction

