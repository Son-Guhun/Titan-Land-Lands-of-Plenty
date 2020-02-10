library UILib

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

endlibrary