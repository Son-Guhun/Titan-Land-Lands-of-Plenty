library AdvChatBoxController requires OSKeyLib, AdvChatBoxView, PlayerUtils, EditBoxFix, IsMouseOnButton

globals
    private framehandle g_defaultChatBox
endglobals

function FindChatBox takes nothing returns framehandle
    local framehandle origin = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    local integer i = BlzFrameGetChildrenCount(origin) - 1
    local framehandle frame
    
    loop
    exitwhen i < 0
        set frame = BlzFrameGetChild(origin, i)
    
        if BlzFrameGetHeight(frame) == 0.03 and BlzFrameGetWidth(frame) == 0.4 then
            return frame
        endif
        set i = i - 1
    endloop

    return null
endfunction

module AdvChatBoxController

    private static integer timerTicks = 0
    private static string lastText = ""  // async. stores the last text held by the chat box
    private static boolean in = false  // async
    private static string buffer = ""  // async
    
    // To make these arrays hashtable-based, simple extract them into a separate PlayerData struct and refactor.
    private static real array timeStamps  // stores last timestamp of the last time a player typed
    private static string array lastSentText  // stores last sent text of a player. Used to avoid sending duplicate messages.
    private static real array lastSentTimestamp  // stores the timestamp when a player last sent a msg. Used to avoid sending duplicate messages.
    
    public static method operator defaultChatBox takes nothing returns framehandle
        return g_defaultChatBox
    endmethod
    
    private static method setTypingText takes integer trailingDots returns nothing
        local string msg = ""
        local integer pId = 0
        local real elapsed = Timeline.game.elapsed
        local integer playerCount = 0
        
        if elapsed > 3. then
            loop
                exitwhen pId == bj_MAX_PLAYERS
                if User.fromLocal() != pId and elapsed - timeStamps[pId] < 3.0 then
                    if playerCount > 0 then
                        if playerCount > MAX_TYPING_DISPLAY_COUNT then
                            set msg = "Many players"
                            exitwhen true
                        endif
                        set msg = msg + ", " + getDisplayName(Player(pId))
                    else
                        set msg = getDisplayName(Player(pId))
                    endif
                    set playerCount = playerCount + 1
                endif
                set pId = pId + 1
            endloop
        endif
        
        if msg != "" then
            if playerCount == 1 then
                set msg = msg + " is typing" + SubString("...", 3-trailingDots, 3)
            else
                set msg = msg + " are typing" + SubString("...", 3-trailingDots, 3)
            endif
        endif
        
        call BlzFrameSetText(AdvChatBox.typingIndicator, msg)
    endmethod

    private static method onTimer takes nothing returns nothing
        local string msg = ""
    
        call setTypingText(timerTicks)
        set timerTicks = ModuloInteger(timerTicks + 1, 4)
        
        set msg = parseChatSymbols(BlzFrameGetText(AdvChatBox.editBox))
        if BlzFrameGetText(AdvChatBox.editBox) != msg then
            call BlzFrameSetText(AdvChatBox.editBox, msg)
        endif
        if msg != lastText then
            if msg != "" then
                if StringLength(msg) > 120 then
                    call BlzFrameSetPoint(AdvChatBox.charCounter, FRAMEPOINT_RIGHT, AdvChatBox.editBox, FRAMEPOINT_TOPRIGHT, 0.05, 0.003)
                else
                    call BlzFrameSetPoint(AdvChatBox.charCounter, FRAMEPOINT_RIGHT, AdvChatBox.editBox, FRAMEPOINT_RIGHT, 0.05, 0)
                endif
                call BlzFrameSetText(AdvChatBox.charCounter, I2S(StringLength(msg))+"/255")
            
                if timerTicks == 0 then
                    set lastText = msg
                    call BlzFrameClick(AdvChatBox.syncButton)
                endif
            else
                call BlzFrameSetText(AdvChatBox.charCounter, "0/255")
                call BlzFrameSetPoint(AdvChatBox.charCounter, FRAMEPOINT_RIGHT, AdvChatBox.editBox, FRAMEPOINT_RIGHT, 0.05, 0)
            endif
        endif
    endmethod

    private static method editBoxEnter takes nothing returns nothing
        local string msg = BlzGetTriggerFrameText()
        local integer len = StringLength(msg)
        local player trigP = GetTriggerPlayer()
        local User pId = User[trigP]
        
        if not (msg == lastSentText[pId] and Timeline.game.elapsed < lastSentTimestamp[pId] + .5) then
            if len == 0 then
                if User.Local == trigP then
                    call BlzFrameSetVisible(AdvChatBox.editBox, false)
                    call BlzFrameSetFocus(AdvChatBox.editBox, false)
                endif
            elseif len > 128 then
                call sendMessageHandler(trigP, SubString(msg, 0, 128), SubString(msg, 128, len))
            else
                call sendMessageHandler(trigP, msg, "")
            endif
            
            set timeStamps[pId] = 0.
            set lastSentText[pId] = msg
            set lastSentTimestamp[pId] = Timeline.game.elapsed
        endif
    endmethod

    private static method handleButton takes player whichPlayer, framehandle whichButton returns nothing
        local string temp

        if whichButton == AdvChatBox.closeButton then
            set timeStamps[GetPlayerId(whichPlayer)] = 0.
            if User.Local == whichPlayer then
                call BlzFrameSetVisible(AdvChatBox.editBox, false)
                call BlzFrameSetFocus(AdvChatBox.editBox, false)
            endif
        elseif whichButton == AdvChatBox.syncButton then
            set timeStamps[GetPlayerId(whichPlayer)] = Timeline.game.elapsed  // This invisible button is used to sync last typing time for players
        elseif whichButton == AdvChatBox.speakerButton then
            // to do
        else
            set isIC[User[whichPlayer]] = not isIC[User[whichPlayer]]
            
            if isIC[User[whichPlayer]] then
                set temp = "IC"
            else
                set temp = "OOC"
            endif
            
            if User.Local == whichPlayer then
                call BlzFrameSetText(AdvChatBox.sendButton, temp)
                call BlzFrameSetEnable(AdvChatBox.speakerButton, isIC[User[whichPlayer]])
                call BlzFrameSetFocus(AdvChatBox.editBox, true)
                if whichButton == AdvChatBox.sendButton then
                    set temp = BlzFrameGetText(AdvChatBox.editBox)
                    call BlzFrameSetText(AdvChatBox.editBox, buffer)
                    set buffer = temp
                endif
            endif
        endif
        
        if User.Local == whichPlayer then
            call BlzFrameSetEnable(whichButton, false)
            call BlzFrameSetEnable(whichButton, true)
        endif
    endmethod

    private static method onHotkey takes nothing returns boolean
        if BlzGetTriggerPlayerKey() == OSKEY_RETURN and BlzGetTriggerPlayerMetaKey() == MetaKeys.SHIFT+MetaKeys.CTRL then
            if User.Local == GetTriggerPlayer() then
                call BlzFrameSetVisible(defaultChatBox, false)
                call BlzFrameSetVisible(AdvChatBox.editBox, true)
                call BlzFrameSetFocus(AdvChatBox.editBox, true)
            endif

            call EditBoxFix_SetPlayerFocusedEditBox(GetTriggerPlayer(), AdvChatBox.editBox)
        elseif BlzGetTriggerPlayerKey() == OSKEY_ESCAPE and BlzGetTriggerPlayerMetaKey() == MetaKeys.SHIFT then 
            call handleButton(GetTriggerPlayer(), AdvChatBox.closeButton)
        endif
        
        return true
    endmethod

    private static method onButton takes nothing returns nothing
        call handleButton(GetTriggerPlayer(), BlzGetTriggerFrame())
    endmethod

    //===========================================================================
    private static method onStart takes nothing returns nothing
        local trigger eventHandler
        local integer pId = 0

        set g_defaultChatBox = FindChatBox()
        call TimerStart(GetExpiredTimer(), 1/4., true, function thistype.onTimer)
        

        set eventHandler = CreateTrigger()
        call TriggerAddAction(eventHandler, function thistype.editBoxEnter)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.editBox, FRAMEEVENT_EDITBOX_ENTER)
        
     
        set eventHandler = CreateTrigger()
        call TriggerAddAction(eventHandler, function thistype.onButton)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.syncButton, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.closeButton, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.speakerButton, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.sendButton, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(eventHandler, AdvChatBox.oocButtonNoBuffer, FRAMEEVENT_CONTROL_CLICK)

        call OSKeys.ESCAPE.register()
        call OSKeys.RETURN.register()
        call OSKeys.addListener(Condition(function thistype.onHotkey))
        call OSKeys.addHoldListener(Condition(function thistype.onHotkey))
        
        call EditBoxFix_Register(AdvChatBox.editBox)
        call IsMouseOnButton_Register(AdvChatBox.closeButton)
        call IsMouseOnButton_Register(AdvChatBox.speakerButton)
        call IsMouseOnButton_Register(AdvChatBox.sendButton)
        call IsMouseOnButton_Register(AdvChatBox.oocButtonNoBuffer)
    endmethod

    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
    endmethod
endmodule

endlibrary