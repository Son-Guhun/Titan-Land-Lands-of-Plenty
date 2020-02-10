library GameController initializer Init requires UILib, MainMenuController

private function onClick takes nothing returns nothing
    local framehandle trigButton = BlzGetTriggerFrame()
    local player trigP = GetTriggerPlayer()

    if trigButton == UpperButtonBar.buttons[7] then
        call MainMenuController_controller.enable(trigP, not MainMenuController_controller.isEnabled(trigP))
    endif
    
    if trigP == User.Local then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

private function onHotkey takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    
    if BlzGetTriggerPlayerIsKeyDown() then
        if trigP == User.Local and BlzGetTriggerPlayerKey() == OSKEY_ESCAPE then
            call BlzFrameClick(UpperButtonBar.buttons[7])
        endif
    endif

    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger() //The Trigger Handling the Frameevent
    call TriggerAddAction(trig, function onClick) //Function onClick will run when mainButton is clicked
    
    call BlzTriggerRegisterFrameEvent(trig, UpperButtonBar.buttons[7], FRAMEEVENT_CONTROL_CLICK)
    call OSKeys.addListener(Condition(function onHotkey))
    
    call OSKeys.ESCAPE.register()
endfunction

endlibrary