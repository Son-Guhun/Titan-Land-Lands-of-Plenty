library UILib

module UIViewInit
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onTimer)
    endmethod
endmodule

struct UIView extends array
    // Credits to Kazeon for UIUtils library, where this code was taken from.
    // https://www.hiveworkshop.com/threads/ui-utils-v1-05.320005/

    readonly static integer ResolutionWidth = 1920
    readonly static integer ResolutionHeight = 1080
    readonly static real maxX = 0.933
    readonly static real minX = -0.133
    
    readonly static framehandle LEFT_BORDER = null
    readonly static framehandle RIGHT_BORDER
    
    
    static method operator PXTODPI takes nothing returns real
        return 0.6/ResolutionHeight
    endmethod
   
    static method operator DPITOPX takes nothing returns real
        return ResolutionHeight/0.6
    endmethod
   
    static method operator FrameBoundWidth takes nothing returns real
        return (ResolutionWidth-ResolutionHeight/600.*800.)/2.
    endmethod
    
    static method getScreenPosX takes integer x returns real
        return (-UIView.FrameBoundWidth+x)*UIView.PXTODPI
    endmethod
    
    static method getScreenPosY takes integer y returns real
        return y*UIView.PXTODPI
    endmethod
    
    static method onTimer takes nothing returns nothing
        local integer w = BlzGetLocalClientWidth()
        local integer h = BlzGetLocalClientHeight()
        local framehandle ConsoleUIBackdrop
        
        if LEFT_BORDER == null then
            set ConsoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        
            set LEFT_BORDER = BlzCreateFrameByType("FRAME", "LeftBorderFrame", ConsoleUIBackdrop, "", 0)
            set RIGHT_BORDER = BlzCreateFrameByType("FRAME", "RightBorderFrame", ConsoleUIBackdrop, "", 0)
            
            call TimerStart(GetExpiredTimer(), 0.5, true, function thistype.onTimer)
            set ResolutionWidth = 0
            set ResolutionHeight = 0
            
            call BlzLoadTOCFile("war3mapImported\\boxedtext.toc")  // Used for tooltips
        endif
    
        if ResolutionWidth != w or ResolutionHeight != h then
            set ResolutionWidth = w
            set ResolutionHeight = h
            
            set minX = getScreenPosX(0)
            set maxX = getScreenPosX(ResolutionWidth)
            call BlzFrameSetAbsPoint(LEFT_BORDER, FRAMEPOINT_TOPLEFT, minX, 0.6)
            call BlzFrameSetAbsPoint(RIGHT_BORDER, FRAMEPOINT_TOPRIGHT, maxX, 0.6)
            call BlzFrameSetSize(LEFT_BORDER, 0.001, 0.6)
            call BlzFrameSetSize(RIGHT_BORDER, 0.001, 0.6)
        endif
    endmethod
    
    implement UIViewInit
       
endstruct

function GetScreenPosX takes integer x returns real
    return UIView.getScreenPosX(x)
endfunction

function GetScreenPosY takes integer y returns real
    return UIView.getScreenPosY(y)
endfunction

struct View4by3 extends array

    static constant method operator width takes nothing returns real
        return 0.8
    endmethod
    
    static constant method operator height takes nothing returns real
        return 0.6
    endmethod
    
    static constant method operator w takes nothing returns real
        return width
    endmethod
    
    static constant method operator h takes nothing returns real
        return height
    endmethod
    
endstruct

function LocalFrameSetText takes player whichPlayer, framehandle frame, string text returns nothing
    if whichPlayer == User.Local then
        call BlzFrameSetText(frame, text)
    endif
endfunction

function CreateTooltip takes framehandle frame, string title, real sizeX, real sizeY, real xOffset, real yOffset returns framehandle
    local framehandle tooltip = BlzCreateFrame("BoxedText", frame, 0, 0)

    call BlzFrameSetTooltip(frame, tooltip)

    call BlzFrameSetPoint(tooltip, FRAMEPOINT_LEFT, frame, FRAMEPOINT_RIGHT, xOffset, yOffset)
    call BlzFrameSetSize(tooltip, sizeX, sizeY)
    call BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle",0), title)
   
    set tooltip = null
    return BlzGetFrameByName("BoxedTextValue",0)
endfunction

endlibrary