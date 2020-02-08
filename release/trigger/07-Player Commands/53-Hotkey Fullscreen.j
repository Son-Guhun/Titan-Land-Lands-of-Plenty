scope Fullscreen

globals
    private framehandle ConsoleUIBackdrop
endglobals

function onPress takes nothing returns nothing
    local boolean enabled
    if BlzGetTriggerPlayerKey() == OSKEY_Z and BlzGetTriggerPlayerIsKeyDown() and BitAny(BlzGetTriggerPlayerMetaKey(), MetaKeys.ALT) and GetLocalPlayer() == GetTriggerPlayer() then
        set enabled = BlzFrameIsVisible(ConsoleUIBackdrop)
        call BlzHideOriginFrames(enabled)
        call BlzEnableUIAutoPosition(not enabled)
        call BlzFrameSetVisible(ConsoleUIBackdrop, not enabled)
    endif
endfunction

//===========================================================================
function InitTrig_Hotkey_Fullscreen takes nothing returns nothing
    call OSKeys.Z.register()
    call OSKeys.addListener(Condition(function onPress))
    set ConsoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
endfunction

endscope
