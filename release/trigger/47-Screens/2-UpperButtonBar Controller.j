library UpperButtonBarController initializer Init requires UILib, MainMenuController

globals
    private sound clickSound
    private sound clickSoundBig
endglobals

private function onClick takes nothing returns nothing
    local framehandle trigButton = BlzGetTriggerFrame()
    local player trigP = GetTriggerPlayer()

    if trigButton == UpperButtonBar.buttons[7] then
        if MainMenuController_controller.isEnabled(trigP) then
            call MainMenuController_controller.enable(trigP, false)
            call StartSoundForPlayerBJ(trigP, clickSoundBig)
        else
            call MainMenuController_controller.enable(trigP, true)
            call StartSoundForPlayerBJ(trigP, clickSound)        
        endif
    elseif trigButton == UpperButtonBar.buttons[5] then
        if DecorationBrowserController_controller.isEnabled(trigP) then
            call DecorationBrowserController_controller.enable(trigP, false)
            call StartSoundForPlayerBJ(trigP, clickSoundBig)
        else
            call DecorationBrowserController_controller.enable(trigP, true)
            call StartSoundForPlayerBJ(trigP, clickSound) 
        endif
    endif
endfunction

private function onTimer takes nothing returns nothing
    if (BlzFrameGetEnable(UpperButtonBar.buttons[1])) != UpperButtonBar.isEnabled then
        set UpperButtonBar.isEnabled = not UpperButtonBar.isEnabled
        call BlzFrameSetEnable(UpperButtonBar.buttons[7], UpperButtonBar.isEnabled)
    endif
endfunction

private function onHotkey takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    
    if BlzGetTriggerPlayerIsKeyDown() and BlzGetTriggerPlayerMetaKey() == MetaKeys.CTRL then
        if trigP == User.Local and BlzGetTriggerPlayerKey() == OSKEY_F4 then
            call BlzFrameClick(UpperButtonBar.buttons[7])
        endif
    endif

    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger() //The Trigger Handling the Frameevent
    call TriggerAddAction(trig, function onClick) //Function onClick will run when mainButton is clicked
    
    call TimerStart(CreateTimer(), 1/32., true, function onTimer)
    
    set clickSound = CreateSound("Sound\\Interface\\GamePause.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundVolume(clickSound, 100)
    call SetSoundChannel(clickSound, 8)
    call SetSoundDuration(clickSound, 827)
    set clickSoundBig = CreateSound("Sound\\Interface\\BigButtonClick.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundVolume(clickSoundBig, 100)
    call SetSoundChannel(clickSoundBig, 8)
    call SetSoundDuration(clickSoundBig, 390)
    call BlzTriggerRegisterFrameEvent(trig, UpperButtonBar.buttons[5], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, UpperButtonBar.buttons[7], FRAMEEVENT_CONTROL_CLICK)
    call OSKeys.addListener(Condition(function onHotkey))
    
    call OSKeys.F4.register()
endfunction

endlibrary