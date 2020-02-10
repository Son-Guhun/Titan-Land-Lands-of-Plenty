library TerrainEditorUIController initializer Init requires UILib, PlayerUtils, BitFlags, TerrainEditorUIView

globals
    public boolean heightEnabled = false
    public ScreenController controller
endglobals

function ButtonCallBack takes nothing returns nothing
    local framehandle trigButton = BlzGetTriggerFrame()
    local string buttonName = BlzFrameGetText(trigButton)
    local player trigP = GetTriggerPlayer()
    
    if buttonName == "Heighting: Hill" then
        call LocalFrameSetText(trigP, trigButton, "Heighting: None")
        call TerrainEditor_SetHeightTool(trigP, 0)
    elseif buttonName == "Heighting: None" then
        if heightEnabled then
            call LocalFrameSetText(trigP, trigButton, "Heighting: Hill")
            call TerrainEditor_SetHeightTool(trigP, 1)
        else
            call DisplayTextToPlayer(trigP, 0., 0., "The Titan must enable height with |cffffff00-editor enable height|r. Not recommended for multiplayer.")
        endif
    elseif buttonName == "Texturing: On" then
        call LocalFrameSetText(trigP, trigButton, "Texturing: Off")
        call TerrainEditor_EnablePainting(trigP, false)
    elseif buttonName == "Texturing: Off" then
        call LocalFrameSetText(trigP, trigButton, "Texturing: On")
        call TerrainEditor_EnablePainting(trigP, true)
    endif
    
    if trigP == User.Local then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

private function onPress takes nothing returns boolean
    local integer number = GetHandleId(BlzGetTriggerPlayerKey()) - $30
    local player trigP = GetTriggerPlayer()
    
    if controller.isEnabled(trigP) then
        call BJDebugMsg("a")
        
        if BlzGetTriggerPlayerIsKeyDown() then
            if number > 0 and number < 6 then
                call TerrainEditor_SetBrushSize(trigP, number*2-1)
            elseif trigP == User.Local and BlzGetTriggerPlayerKey() == OSKEY_H then
                call BlzFrameClick(TerrainEditorUIView_mainFrame["heightButton"])
            elseif trigP == User.Local and BlzGetTriggerPlayerKey() == OSKEY_P then
                call BlzFrameClick(TerrainEditorUIView_mainFrame["paintButton"])
            endif
        endif
    endif
    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger() //The Trigger Handling the Frameevent
    call TriggerAddAction(trig, function ButtonCallBack) //Function ButtonCallBack will run when mainButton is clicked
    
    call BlzTriggerRegisterFrameEvent(trig, TerrainEditorUIView_mainFrame["paintButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, TerrainEditorUIView_mainFrame["heightButton"], FRAMEEVENT_CONTROL_CLICK)
    
    call OSKeys.KEY1.register()
    call OSKeys.KEY2.register()
    call OSKeys.KEY3.register()
    call OSKeys.KEY4.register()
    call OSKeys.KEY5.register()
    call OSKeys.KEY6.register()
    call OSKeys.KEY7.register()
    call OSKeys.KEY8.register()
    call OSKeys.KEY9.register()
    call OSKeys.H.register()
    call OSKeys.P.register()
    set controller = ScreenController.create(TerrainEditorUIView_mainFrame, Condition(function onPress))
endfunction

endlibrary