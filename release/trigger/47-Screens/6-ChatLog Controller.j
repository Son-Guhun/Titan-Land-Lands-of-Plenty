library ChatLogController initializer Init requires UILib, ChatLogView

globals
    public ScreenController controller
    private boolean ooc = false
endglobals

private function onClick takes nothing returns nothing
    local framehandle trigButton = BlzGetTriggerFrame()
    local player trigP = GetTriggerPlayer()
    local boolean show
    
    if trigButton == ChatLogView_mainFrame["hideButton"] then
        set show = not BlzFrameIsVisible(ChatLogView_mainFrame["closeButton"])
        call BlzFrameSetVisible(ChatLogView_mainFrame["closeButton"], show)
        call BlzFrameSetVisible(ChatLogView_mainFrame["IC log"], show and not ooc)
        call BlzFrameSetVisible(ChatLogView_mainFrame["OOC log"], show and ooc)
        call BlzFrameSetVisible(ChatLogView_mainFrame["switchButton"], show)
        
        if show then
            call BlzFrameSetText(trigButton, "Hide")
        else
            call BlzFrameSetText(trigButton, "Show")
        endif
    elseif trigButton == ChatLogView_mainFrame["switchButton"] then
        set ooc = not ooc
        call BlzFrameSetVisible(ChatLogView_mainFrame["IC log"], not ooc)
        call BlzFrameSetVisible(ChatLogView_mainFrame["OOC log"], ooc)
        if ooc then
            call BlzFrameSetText(trigButton, "IC")
            call BlzFrameSetSize(trigButton, 0.04, 0.03)
        else
            call BlzFrameSetText(trigButton, "OOC")
            call BlzFrameSetSize(trigButton, 0.05, 0.03)
        endif
    elseif trigButton == ChatLogView_mainFrame["closeButton"] then
        call controller.enable(trigP, false)
    endif
    
    if trigP == User.Local then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction


//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger() //The Trigger Handling the Frameevent
    call TriggerAddAction(trig, function onClick) //Function onClick will run when mainButton is clicked
    
    call BlzTriggerRegisterFrameEvent(trig, ChatLogView_mainFrame["hideButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, ChatLogView_mainFrame["switchButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(trig, ChatLogView_mainFrame["closeButton"], FRAMEEVENT_CONTROL_CLICK)
    
    set controller = ScreenController.create(ChatLogView_mainFrame, null)
endfunction

endlibrary