library ListBox requires Table, PlayerUtils

/*
  DOCUMENTATION

This library defines the ListBoxTemplate module, which is used to implement ListBoxes.
  
  
To implement this module in a struct, you will need to define the following fields/methods before the line in which the module is implemented:
*/

//! novjass
struct Example extends array
    static framepointtype startFramepoint = FRAMEPOINT_TOP  // absolute framepoint that will be set for the first button
    static real startPointX = 0.4  // X center for the framepoint of the first button
    static real startPointY = 0.57 // Y for the framepoint of the first button
    static constant integer numberOfEntries = 3  // Number of buttons displayed
    static integer initialSize = 6  // Initial number of options
    static constant string frameName = "BrowserButton"  // Frame used for buttons
    static constant real sizeX = 0.125  // X size of the whole listbox
    static constant real sizeY = 0.028*numberOfEntries  // Y size of the whole listbox
    static constant boolean LISTBOX_SKIP_INIT = true  // If this is not set, then you must create a listBoxInit function

    // Called when a button is updated.
    // This entire function is locally executed. Avoid functions that change game state.
    static method updateFrame takes integer frameIndex, integer listIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(rawcodes[listIndex]))
    endmethod
    
    // Called when the frames are created at map start.
    // You can override the value of buttons[i] here
    static method onCreateFrame takes integer frameIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(rawcodes[frameIndex]))
    endmethod
    
    //     Called when a player clicks on a button. 'listIndex' will depend on the current number of total
    // options for a player. 
    // If true is returned, then the list will be refreshed, calling updateFrame for all frames.
    static method onClickHandler takes player trigP, integer frameIndex, integer listIndex returns boolean
        call BJDebugMsg(BlzFrameGetText(buttons[frameIndex]))
        call BJDebugMsg(I2S(listIndex))
    endmethod

    implement ListBoxTemplate  // Important: template should be implemented last
endstruct

module ListBoxTemplate

    // Fields
    //========================
    readonly static framehandle array buttons  // contains all the buttons in the listbox
    readonly static framehandle scrollBar
    
    // Methods
    //========================

    // From the index of a frame in the buttons array, returns the index of the value held by that frame in the list of the given player
    static method getListIndex takes player whichPlayer, integer frameIndex returns integer
    
    // Refresh the frames in a list, calling updateFrame for each.
    static method refreshList takes player whichPlayer returns nothing
    
    // Changes the size of the list displayed by the listBox (i.e., how far down the scrollbar will go).
    static method changeSize takes player whichPlayer, integer newSize returns nothing
endmodule
//! endnovjass


// SOURCE CODE BELOW
///////////////////////////////////////////////

module ListBoxTemplate
    readonly static framehandle array buttons  // contains all the buttons in the listbox
    readonly static framehandle scrollBar
    
    // Static tables (basically arrays). These are private (but can't make them so due to module limitations)
    private static key tab  // a map from handleID to button frame, using a static Table
    private static key lastValue_tab // for each player, stores the last value of the scrollBar fram
    private static key sizes_tab // for each player, stores the size of the list displayed by the listbox (all items)
    private static key wheelSpins_tab // for each player, stores how many mouse wheel spins they have made whose value changed event has not triggered
    
    
    // These are supposed to be private, but private module operators are not supported for some reason.
    /* private */ static method operator handleId2Index takes nothing returns Table
        return tab
    endmethod

    /* private */ static method operator lastValue takes nothing returns Table
        return lastValue_tab
    endmethod
    
    /* private */ static method operator sizes takes nothing returns Table
        return sizes_tab
    endmethod
    
    /* private */ static method operator wheelSpins takes nothing returns Table
        return wheelSpins_tab
    endmethod
    

    // Minimum value for list size
    static constant method operator minValue takes nothing returns integer
        return numberOfEntries - 1
    endmethod
    
    // Returns the position of a frame in the listbox
    static method getFrameIndex takes framehandle frame returns integer
        return handleId2Index[GetHandleId(frame)]
    endmethod
    
    // From the index of a frame in the buttons array, returns the index of the value held by that frame in the list of the given player
    static method getListIndex takes player whichPlayer, integer frameIndex returns integer
        local integer pId = User[whichPlayer]
        return sizes[pId] - lastValue[pId] + frameIndex
    endmethod
    
    private static method updateList takes player whichPlayer, integer i returns nothing
            local integer min
            local integer j
            local integer size

            if i < 0 then
                set i = lastValue[User[whichPlayer]]
            else
                set lastValue[User[whichPlayer]] = i
            endif
            
            set min = i - numberOfEntries
            set j = 0
            set size = sizes[User[whichPlayer]]
            
            if User.Local == whichPlayer then
                loop
                exitwhen i == min
                    call updateFrame(j, size - i)
                    set i = i - 1
                    set j = j + 1
                endloop
            endif
    endmethod
    
    static method refreshList takes player whichPlayer returns nothing
        call updateList(whichPlayer, -1)
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

    private static method onValue takes nothing returns nothing
        local integer i = R2I(BlzGetTriggerFrameValue())
        local User pId = User[GetTriggerPlayer()]
        
        if i != lastValue[pId] and wheelSpins[pId] == 0 then
            call updateList(GetTriggerPlayer(), i)
        endif
        
        set wheelSpins[pId] = IMaxBJ(wheelSpins[pId] - 1, 0)
    endmethod

    private static method onWheel takes nothing returns nothing
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
        local integer frameIndex = handleId2Index[GetHandleId(frame)]
        local User pId = User[GetTriggerPlayer()]
        
        if User.fromLocal() == pId then
            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
        endif
        
        if onClickHandler(GetTriggerPlayer(), frameIndex, sizes[pId] - lastValue[pId] + frameIndex) then
            call refreshList(GetTriggerPlayer())
        endif
        
    endmethod
    
    private static method onStart takes nothing returns nothing
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
            set handleId2Index[GetHandleId(buttons[i-1])] = i-1
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
    
        call DestroyTimer(GetExpiredTimer())
    endmethod

    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
    endmethod
endmodule

endlibrary