library IsMouseOnWorld requires WidescreenUI
/*
Problem:
When using the mouse natives, a lot of the time we don't want to do anything if the player was actually
clicking a UI element, not the game world.

Solution:
This library provides functions that determine if a player's mouse is on the game world.

------------------------------------------------------------------
                                API
------------------------------------------------------------------

// This function returns an async value.
function IsMouseOnWorld takes nothing returns boolean

// This function returns a synced value.
function IsPlayerMouseOnWorld takes player whichPlayer returns boolean

// When mouse is on the top menu bar, BlzGetPlayerMouseX/Y will return 0 for both coords.
// It's basically impossible for a player to actually have their mouse on point (0, 0).
// That means, if both x and y are 0, the mouse is probably on the top bar and not the world.
// Therefore, the following functions are defined, for QoL. They automatically filter out (0,0):

// async
function IsMouseOnWorldCoords takes real x, real y returns boolean

// synced
function IsPlayerMouseOnWorldCoords takes player whichPlayer, real x, real y returns boolean


------------------------------------------------------------------
                           Configuration
------------------------------------------------------------------
*/

public struct Config extends array
    
    // This should be a power of 2. (1/32, 1/64, 1/128, etc.)
    static method operator TIMER_PRECISION takes nothing returns real
        return 1.0 / 32.0
    endmethod

endstruct
/////////////////////////// Source Code ///////////////////////////////////////

globals
    private framehandle tooltip
    private framehandle dummyButtonOn
    private framehandle dummyButtonOut
    
    private boolean onWorld = false
    private boolean array onWorldSync
endglobals

// Filter out (0,0) coords (see documentation above)
private function ValidateCoords takes real x, real y returns boolean
    return x!=0 or y!=0
endfunction

// This returns an async value.
function IsMouseOnWorld takes nothing returns boolean
    return BlzFrameIsVisible(tooltip)
endfunction

// This returns an async value.
function IsMouseOnWorldCoords takes real x, real y returns boolean
    return ValidateCoords(x, y) and IsMouseOnWorld()
endfunction

function IsPlayerMouseOnWorld takes player whichPlayer returns boolean
    return onWorldSync[GetPlayerId(whichPlayer)]
endfunction
    
function IsPlayerMouseOnWorldCoords takes player whichPlayer, real x, real y returns boolean
    return IsPlayerMouseOnWorld(whichPlayer) and ValidateCoords(x, y)
endfunction


private function onButton takes nothing returns nothing
    set onWorldSync[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerFrame() == dummyButtonOn
endfunction

private function onTimer takes nothing returns nothing
    // Everything in this block is async. Do not alter the game state here.
    if BlzFrameIsVisible(tooltip) != onWorld then
        set onWorld = not onWorld
        if onWorld then
            call BlzFrameClick(dummyButtonOn)
        else
            call BlzFrameClick(dummyButtonOut)
        endif
    endif
endfunction

private function onStart takes nothing returns nothing
    local trigger trig = CreateTrigger()
    set tooltip = BlzCreateFrameByType("FRAME", "WorldFrameTooltip", UIView.WorldFrame,"", 0)
    
    call BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_CENTER, 0.4,0.3)
    call BlzFrameSetTooltip(UIView.WorldFrame, tooltip)
    
    set dummyButtonOn = BlzCreateFrameByType("BUTTON", "DummyButton", UIView.WorldFrame,"", 0)
    set dummyButtonOut = BlzCreateFrameByType("BUTTON", "DummyButton", UIView.WorldFrame,"", 0)
    call BlzTriggerRegisterFrameEvent(trig, dummyButtonOn, FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, dummyButtonOut, FRAMEEVENT_CONTROL_CLICK)
    
    call TriggerAddAction(trig, function onButton)
    call TimerStart(GetExpiredTimer(), Config.TIMER_PRECISION, true, function onTimer)
endfunction

private module Init
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function onStart)
    endmethod
endmodule
private struct InitStruct extends array
    implement Init
endstruct

endlibrary