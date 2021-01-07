scope Fullscreen

globals
    private constant integer COMMAND_CARD_ALPHA = 30
endglobals

private function onCommand takes nothing returns boolean
    
    if User.Local == GetTriggerPlayer() then
        if LoPUI_altZEnabled then
            call LoPHints.FULLSCREEN.displayToPlayer(User.Local)
            call FullScreen(not IsFullScreen(), COMMAND_CARD_ALPHA)
        endif
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Fullscreen takes nothing returns nothing
    call LoP_Command.create("-fullscreen", ACCESS_USER, Condition(function onCommand))
endfunction

endscope
