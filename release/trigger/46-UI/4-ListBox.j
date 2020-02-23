library ListBox requires Table, PlayerUtils

module ListBoxTemplate
    readonly static framehandle array buttons
    readonly static framehandle scrollBar
    readonly static integer array lastValue
    readonly static integer array sizes
    readonly static integer array wheelSpins
    
    private static key tab
    
    static constant method operator minValue takes nothing returns integer
        return numberOfEntries - 1
    endmethod
    
    static method getListIndex takes player whichPlayer, integer frameIndex returns integer
        local integer pId = User[whichPlayer]
        return sizes[pId] - lastValue[pId] + frameIndex
    endmethod
    
    private static method updateList takes player whichPlayer, integer i returns nothing
            local integer min = i - numberOfEntries
            local integer j = 0
            local integer size = sizes[GetPlayerId(GetTriggerPlayer())]
            
            set lastValue[User[whichPlayer]] = i
            if User.Local == whichPlayer then
                loop
                exitwhen i == min
                    call updateFrame(j, size - i)
                    set i = i - 1
                    set j = j + 1
                endloop
            endif
    endmethod
    
    static method changeSize takes player whichPlayer, integer newSize returns nothing
        local integer i = 0
        set sizes[User[whichPlayer]] = IMaxBJ(newSize, minValue)
        
        if User.Local == whichPlayer then
            call BlzFrameSetMinMaxValue(scrollBar, minValue, IMaxBJ(newSize, minValue))
            call BlzFrameSetValue(scrollBar, newSize)
            
            loop
                exitwhen i == numberOfEntries
                if i > newSize then
                    call BlzFrameSetEnable(buttons[i], false)
                else
                    call BlzFrameSetEnable(buttons[i], true)
                endif
                set i = i + 1
            endloop
        endif
        call updateList(whichPlayer, IMaxBJ(newSize, minValue))
        

    endmethod

    static method onValue takes nothing returns nothing
        local integer i = R2I(BlzGetTriggerFrameValue())
        local User pId = User[GetTriggerPlayer()]
        
        if i != lastValue[pId] and wheelSpins[pId] == 0 then
            call updateList(GetTriggerPlayer(), i)
        endif
        
        set wheelSpins[pId] = IMaxBJ(wheelSpins[pId] - 1, 0)
    endmethod

    static method onWheel takes nothing returns nothing
        local player trigP = GetTriggerPlayer()
        local integer pId = GetPlayerId(trigP)
        local real value = RMaxBJ(RMinBJ(sizes[pId], lastValue[pId] + BlzGetTriggerFrameValue()/120.), minValue)
        
        
        set wheelSpins[pId] = wheelSpins[pId] + 1
        if User.Local == trigP then
            if BlzFrameGetValue(scrollBar) == lastValue[pId] then
                call BlzFrameSetValue(scrollBar, value)
            else
                call BlzFrameSetValue(scrollBar, BlzFrameGetValue(scrollBar))  // User manually changed scrollBar, keep value
            endif
        endif
        call updateList(trigP, R2I(value))
    endmethod
    
    static method onClick takes nothing returns nothing
        local framehandle frame = BlzGetTriggerFrame()
        local integer frameIndex = Table(tab)[GetHandleId(frame)]
        local User pId = User[GetTriggerPlayer()]
        
        call onClickHandler(GetTriggerPlayer(), frameIndex, sizes[pId] - lastValue[pId] + frameIndex)
        
        if User.fromLocal() == pId then
            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
        endif
    endmethod

    private static method onInit takes nothing returns nothing
        local framehandle mainFrame
        local trigger clickHandler = CreateTrigger()
        local trigger wheelHandler = CreateTrigger()
        local trigger valueHandler = CreateTrigger()
        local integer i = 0
        
        set mainFrame = BlzCreateFrameByType("FRAME", "ListBoxContainer", parentFrame, "", 0)
        
        set scrollBar = BlzCreateFrameByType( "SLIDER", "Test", mainFrame, "QuestMainListScrollBar", 0 )
        call BlzFrameClearAllPoints(scrollBar)
        
        call BlzTriggerRegisterFrameEvent(valueHandler, scrollBar, FRAMEEVENT_SLIDER_VALUE_CHANGED)
        call TriggerAddAction(valueHandler, function thistype.onValue)
        
        call BlzTriggerRegisterFrameEvent(wheelHandler, scrollBar, FRAMEEVENT_MOUSE_WHEEL)
        call TriggerAddAction(wheelHandler, function thistype.onWheel)

        call TriggerAddAction(clickHandler, function thistype.onClick)
        
        static if not thistype.LISTBOX_SKIP_INIT then
            call listBoxInit(valueHandler, wheelHandler, clickHandler)
        endif
        
        loop
            exitwhen i == bj_MAX_PLAYERS
            set sizes[i] = initialSize
            set i = i + 1
        endloop
        
        set buttons[0] = BlzCreateFrame(frameName, mainFrame, 0,0)
        call BlzFrameSetAbsPoint(buttons[0], startFramepoint, startPointX, startPointY)
        
        set i = 1
        loop
            call BlzFrameSetSize(buttons[i-1], sizeX, sizeY/numberOfEntries)
            call BlzTriggerRegisterFrameEvent(wheelHandler, buttons[i-1], FRAMEEVENT_MOUSE_WHEEL)
            call BlzTriggerRegisterFrameEvent(clickHandler, buttons[i-1], FRAMEEVENT_CONTROL_CLICK)
            set Table(tab)[GetHandleId(buttons[i-1])] = i-1
            call onCreateFrame(i-1)
            exitwhen i == numberOfEntries
            set buttons[i] = BlzCreateFrame(frameName, mainFrame, 0,0)
            call BlzFrameSetPoint(buttons[i], FRAMEPOINT_TOP, buttons[i-1], FRAMEPOINT_BOTTOM, 0., 0.)            
            set i = i + 1
        endloop
        
        call BlzFrameSetPoint(mainFrame, FRAMEPOINT_TOPLEFT, buttons[0], FRAMEPOINT_TOPLEFT, 0., 0.)
        call BlzFrameSetPoint(mainFrame, FRAMEPOINT_BOTTOMRIGHT, buttons[numberOfEntries-1], FRAMEPOINT_BOTTOMRIGHT, 0., 0) 
        
        call BlzFrameSetPoint(scrollBar, FRAMEPOINT_LEFT, mainFrame, FRAMEPOINT_RIGHT, 0., 0. )
        call BlzFrameSetSize(scrollBar, 0.012, sizeY )
        call BlzFrameSetMinMaxValue(scrollBar, minValue, initialSize)
        call BlzFrameSetValue(scrollBar, initialSize)
        call BlzFrameSetStepSize(scrollBar, 1)
    endmethod
endmodule

endlibrary