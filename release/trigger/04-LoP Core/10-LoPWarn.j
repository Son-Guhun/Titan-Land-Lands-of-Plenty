library LoPWarn requires Timeline, TableStruct

struct LoPChannels extends array

    static method operator ERROR takes nothing returns string
        return "|cffff0000[ERROR]|r"
    endmethod

    static method operator SYSTEM takes nothing returns string
        return "|cffffff00[SYS]|r"
    endmethod

    static method operator WARNING takes nothing returns string
        return "|cffffa500[WARNING]|r"
    endmethod
    
    static method operator HINT takes nothing returns string
        return "|cffffcc00[HINT]|r"
    endmethod

endstruct

struct LoPMsgKeys extends array
    static key NO_UNIT_ACCESS
    static key HERO
    static key LIMIT
    static key INVALID
endstruct

globals
    private real array messageTimestamps  // async
endglobals

function LoP_WarnPlayerTimeout takes player whichPlayer, string channel, integer msgKey, real timeout, string message returns nothing
    set message = channel + " " + message
    
    if msgKey == 0 then 
        call DisplayTextToPlayer(whichPlayer, 0., 0., message)
    else
        if User.Local == whichPlayer then
            if Timeline.game.elapsed > messageTimestamps[msgKey] then
                set messageTimestamps[msgKey] = Timeline.game.elapsed + timeout
                call DisplayTextToPlayer(User.Local, 0., 0., message)
            endif
        endif
    endif
endfunction

function LoP_WarnPlayer takes player whichPlayer, string channel, string message returns nothing
    call LoP_WarnPlayerTimeout(whichPlayer, channel, 0, 0., message)
endfunction

endlibrary