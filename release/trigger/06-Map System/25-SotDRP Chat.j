library SotDRPChat requires ChatLogView
/*
    Defines the SotDRPMessageHandler function, which should be called when a player sends a chat message.
Handles sending messages via DisplayTextToPlayer like SotDRP-style maps, and also handles adding messages
to the custom chat log.

*/

globals
    boolean sotdrp = false  // async. Indicates whether the local player is in sotdrp chat mode
endglobals

function SotDRPMessageHandler takes User pId, string msg, boolean ooc returns nothing
    if ooc then
        set msg = UserColor(pId).hex + "[OOC]|r |cff00ced1" + msg + "|r"
        if sotdrp then
            call DisplayTextToPlayer(User.Local, 0., 0., msg)
        endif
        call BlzFrameAddText(ChatLogView_mainFrame["OOC log"], msg)
    else
        set msg = UserColor(pId).hex + GetPlayerName(pId.handle) + "|r: |cff40e0d0" + msg + "|r"
        if sotdrp then
            call DisplayTextToPlayer(User.Local, 0., 0., msg)
        endif
        call BlzFrameAddText(ChatLogView_mainFrame["IC log"], msg)
    endif
endfunction

endlibrary
