library UILib requires WidescreenUI

// Hack WidescreenUI init to avoid having to start a timer
//! textmacro LoPUILibLoadTOCFiles
    // Used for tooltips
    call BlzLoadTOCFile("war3mapImported\\boxedtext.toc")
//! endtextmacro

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