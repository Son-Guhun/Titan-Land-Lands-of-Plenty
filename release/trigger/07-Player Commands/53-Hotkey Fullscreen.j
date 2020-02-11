scope Fullscreen

private function onPress takes nothing returns boolean
    
    if BlzGetTriggerPlayerKey() == OSKEY_Z and BlzGetTriggerPlayerIsKeyDown() and BitAny(BlzGetTriggerPlayerMetaKey(), MetaKeys.ALT) and GetLocalPlayer() == GetTriggerPlayer() then
        if LoPStdLib_altZEnabled then
            call FullScreen(not IsFullScreen(), 30)
        endif
    endif
    
    return true
endfunction

//===========================================================================
function InitTrig_Hotkey_Fullscreen takes nothing returns nothing
    call OSKeys.Z.register()
    call OSKeys.addListener(Condition(function onPress))
endfunction

endscope
