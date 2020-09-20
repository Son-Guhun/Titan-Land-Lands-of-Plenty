/* This trigger defines the commands:
-rect => Spawns a rect generator
-start => Spawns a race selector
-controller => Spawns a Deco Modifier Controller
*/

function Trig_Commands_Spawn takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string command  = LoP_Command.getCommand()
    local player trigP = GetTriggerPlayer()
    local real x
    local real y
    
    if args == "mouse" then
        set x = Get64TileCenterCoordinate(GetPlayerLastMouseX(trigP))
        set y = Get64TileCenterCoordinate(GetPlayerLastMouseY(trigP))
    else
        set x = GetLocationX(udg_PLAYER_LOCATIONS[GetPlayerId(trigP) - 1])
        set y = GetLocationY(udg_PLAYER_LOCATIONS[GetPlayerId(trigP)- 1])
    endif

    if ( command == "-rect" ) then
        call CreateUnit(trigP, RectGenerator_GENERATOR_ID, x, y, bj_UNIT_FACING)
    elseif ( command == "-start" ) then
        call CreateUnit(trigP, 'e000', x, y, bj_UNIT_FACING)
    elseif ( command == "-controller" ) then
        call CreateUnit(trigP, 'h0KD', x, y, bj_UNIT_FACING)
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Spawn_Stuff takes nothing returns nothing    
    call LoP_Command.create("-start", ACCESS_USER, Condition(function Trig_Commands_Spawn)) /*
    */.addHint(LoPHints.HOTKEY_RACE_SELECTOR) /*
    */.createChained("-rect", ACCESS_USER, Condition(function Trig_Commands_Spawn)) /*
    */.addHint(LoPHints.HOTKEY_RECT_GENERATOR) /*
    */.createChained("-controller", ACCESS_USER, Condition(function Trig_Commands_Spawn))
endfunction

