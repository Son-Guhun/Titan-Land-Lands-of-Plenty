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
    // Used to determine if enough time has passed by for messages that shouldn't occur frequently (see LoP_WarnPlayerTimeout).
    // async
    private real array messageTimestamps  
    
    // Used to determine whether enough time has passed after the last sound was played,
    // async. 
    private real soundTimestamp = 1. // Sounds will only play after this initial value has passed in seconds from game start.
endglobals

function LoP_WarnPlayerTimeout takes player whichPlayer, string channel, integer msgKey, real timeout, string message returns nothing
    local boolean msgSent = false //async
    
    set message = channel + " " + message
    
    if msgKey == 0 then 
        call DisplayTextToPlayer(whichPlayer, 0., 0., message)
        set msgSent = true
    else
        if User.Local == whichPlayer then
            if Timeline.game.elapsed > messageTimestamps[msgKey] then
                set msgSent = true
                set messageTimestamps[msgKey] = Timeline.game.elapsed + timeout
                call DisplayTextToPlayer(User.Local, 0., 0., message)
            endif
        endif
    endif
    
    if User.Local == whichPlayer and msgSent and soundTimestamp < Timeline.game.elapsed then
        
        if channel == LoPChannels.ERROR then
            call StartSound( gg_snd_Error )
            set soundTimestamp = Timeline.game.elapsed + 2.
    
        elseif channel == LoPChannels.WARNING then
            call StartSound( gg_snd_Warning )
            set soundTimestamp = Timeline.game.elapsed + 2.
            
        elseif channel == LoPChannels.HINT then
            call StartSound( gg_snd_Hint )
            set soundTimestamp = Timeline.game.elapsed + 2.
        
        endif
    endif
endfunction

function LoP_WarnPlayer takes player whichPlayer, string channel, string message returns nothing
    call LoP_WarnPlayerTimeout(whichPlayer, channel, 0, 0., message)
endfunction

endlibrary