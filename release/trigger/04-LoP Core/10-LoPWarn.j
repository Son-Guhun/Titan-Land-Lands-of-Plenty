library LoPWarn requires Timeline, TableStruct
/*
=========
 Description
=========

    This library defines LoP_WarnPlayer and LoP_WarnPlayerTimeout, which are used to send system
messages to players. Messages can be sent to different channels, and each channel's tag is prepended
to the message when it is displayed to players.

    To avoid spamming messages when a user issues a command that causes a lot of errors, LoP_WarnPlayerTimeout
can be used to send messages using a unique msgKey. Calls to send messages to that same key are ignored
until the timeout duration has expired. This is async, so it only affects the local player.

=========
 Documentation
=========

. Channels to be used by LoP_WarnPlayerTimeout and LoP_WarnPlayer.
.
constant struct LoPChannels:
    
    string ERROR
    string SYSTEM
    string WARNING
    string HINT
    
. Commonly used msgKeys for LoP_WarnPlayerTimeout.
.
constant struct LoPMsgKeys:

    integer NO_UNIT_ACCESS  -> Used when a player does not have access to a unit.
    integer HERO  -> Used when a command that cannot target heroes is used on a hero.
    integer LIMIT  -> Used when some sort of limit is reached for a command.
    integer INVALID  -> Used when invalid input is passed to a command.
    

Functions:

    nothing LoP_WarnPlayerTimeout(player whichPlayer, string channel, integer msgKey, real timeout, string message)
    .
    . Sends a message to the specified channel, but only if the given msgKey is available.
    .   string channel  -> One of the constants in LoPChannels. Some channels play designated sounds.
    .   integer msgKey  -> if zero, timeout is ignored.
    .   real timeout  -> makes the given msgKey unavailable to new messages for the duration.
    
    
    nothing LoP_WarnPlayer( player whichPlayer, string channel, string message)
    .
    . Sends a message to the specified channel. Uses zero as msgKey, so no timeouts are triggered.

=========
 Examples
=========
*/
//! novjass

function TimeoutExample takes nothing returns nothing

    // Send a message and block LoPMsgKeys.INVALID for the next second.
    call LoP_WarnPlayerTimeout(User.Local, LoPChannels.ERROR, LoPMsgKeys.INVALID, 1., "Invalid input!")
    
    // This call is ignored, because LoPMsgKeys.INVALID is still blocked.
    call LoP_WarnPlayerTimeout(User.Local, LoPChannels.ERROR, LoPMsgKeys.INVALID, 1., "What?!")
    
    // A timeout of 0 can be used to block a msgKey for only a single frame.

endfunction

//! endnovjass
// ================================================================
//  Source Code
// ================================================================

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
    local boolean msgSent = false // async, used to determine whether sound should be played.
    
    if SubString(message, StringLength(message)-3, StringLength(message)) == "\n \n" then
        set message = "\n" + channel + " " + message
    else
        set message = channel + " " + message
    endif
    
    if msgKey == 0 then 
        // No message key given, just send the message.
        call DisplayTextToPlayer(whichPlayer, 0., 0., message)
        set msgSent = true
    else
        // Message key given, block it until timeout expires.
        if User.Local == whichPlayer then
            if Timeline.game.elapsed > messageTimestamps[msgKey] then
                set msgSent = true
                set messageTimestamps[msgKey] = Timeline.game.elapsed + timeout
                call DisplayTextToPlayer(User.Local, 0., 0., message)
            endif
        endif
    endif
    
    // Play sound
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