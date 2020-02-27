library MainMenuController initializer Init requires UILib, MainMenuView, ChatLogController, LoPUI, TerrainEditorUI

globals
    public ScreenController controller
endglobals

private function onClick takes nothing returns nothing
    local framehandle trigButton = BlzGetTriggerFrame()
    local player trigP = GetTriggerPlayer()
    
    if trigButton == MainMenuView_mainFrame["terrainEditor"] then
        call TerrainEditorUI_Activate(GetTriggerPlayer())
        if User.Local == trigP then
            set LoPUI_altZEnabled = false
            call FullScreen(true, 255)
        endif
        call controller.enable(trigP, false)
    elseif trigButton == MainMenuView_mainFrame["sotdrp"] then
        set sotdrp = not sotdrp
        call BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), not sotdrp)
        if sotdrp then
            call BlzFrameSetText(MainMenuView_mainFrame["sotdrp"], "Normal Chat")
        else
            call BlzFrameSetText(MainMenuView_mainFrame["sotdrp"], "SotDRP Chat")
        endif
    elseif trigButton == MainMenuView_mainFrame["freeCamera"] then
        call FreeCam_Enable(trigP, not FreeCam_IsEnabled(trigP))
    elseif trigButton == MainMenuView_mainFrame["chatLogs"] then
        call ChatLogController_controller.enable(trigP, true)
    elseif trigButton == terrainEditorScreen["exitButton"] then
        call TerrainEditorUI_Deactivate(GetTriggerPlayer())
        if User.Local == trigP then
            set LoPUI_altZEnabled = true
            call FullScreen(false, 255)
        endif
    endif
    
    if trigP == User.Local then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

private function onHotkey takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    
    if BlzGetTriggerPlayerIsKeyDown() then
        if trigP == User.Local and BlzGetTriggerPlayerMetaKey() == MetaKeys.CTRL and BlzGetTriggerPlayerKey() == OSKEY_T then
            call BlzFrameClick(MainMenuView_mainFrame["terrainEditor"])
        endif
    endif
    
    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger() //The Trigger Handling the Frameevent
    call TriggerAddAction(trig, function onClick) //Function onClick will run when mainButton is clicked
    
    call BlzTriggerRegisterFrameEvent(trig, MainMenuView_mainFrame["terrainEditor"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, MainMenuView_mainFrame["sotdrp"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, MainMenuView_mainFrame["freeCamera"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, MainMenuView_mainFrame["chatLogs"], FRAMEEVENT_CONTROL_CLICK)
    
    call BlzTriggerRegisterFrameEvent(trig, terrainEditorScreen["exitButton"], FRAMEEVENT_CONTROL_CLICK)
    
    call OSKeys.T.register()
    set controller = ScreenController.create(MainMenuView_mainFrame, Condition(function onHotkey))
endfunction

endlibrary