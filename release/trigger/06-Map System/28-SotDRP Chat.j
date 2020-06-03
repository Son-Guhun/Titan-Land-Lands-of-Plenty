library SotDRPChat requires ChatLogView

globals
    boolean sotdrp = false
    string array playerColors
endglobals

function ChatMessageHandler takes integer id, string msg, boolean ooc returns nothing
    if ooc then
        set msg = playerColors[id] + "[OOC]|r |cff00ced1" + msg + "|r"
        if sotdrp then
            call DisplayTextToPlayer(User.Local, 0., 0., msg)
        endif
        call BlzFrameAddText(ChatLogView_mainFrame["OOC log"], msg)
    else
        set msg = playerColors[id] + "Character|r: |cff40e0d0" + msg + "|r"
        if sotdrp then
            call DisplayTextToPlayer(User.Local, 0., 0., msg)
        endif
        call BlzFrameAddText(ChatLogView_mainFrame["IC log"], msg)
    endif
endfunction

function SotDRP_Chat_Actions takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local integer len = StringLength(msg)
    local integer id = GetPlayerId(GetTriggerPlayer())
    
    if len > 2 then
        if SubString(msg, 0, 2) == "((" then
            call ChatMessageHandler(id, SubString(msg, 2, len), true)
        elseif SubString(msg, len-2, len) == "))" then
            call ChatMessageHandler(id, SubString(msg, 0, len-2), true)
        elseif not (SubString(msg, 0, 1) == "-" or SubString(msg, 0, 1) == "'") then
            call ChatMessageHandler(id, msg, false)
        endif
    endif
            
endfunction

//===========================================================================
function InitTrig_SotDRP_Chat takes nothing returns nothing
    local User pId = 0
    
    set gg_trg_SotDRP_Chat = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SotDRP_Chat, function SotDRP_Chat_Actions )
    
    loop
        exitwhen pId == bj_MAX_PLAYERS
        if GetPlayerController(pId.handle) == MAP_CONTROL_USER then
            call TriggerRegisterPlayerChatEvent(gg_trg_SotDRP_Chat, pId.handle, "", false)
        endif
        set pId = pId + 1
    endloop
    
    set playerColors[0] = "|c00ff0303"
    set playerColors[1] = "|c000042ff"
    set playerColors[2] = "|c001ce6b9"
    set playerColors[3] = "|c00540081"
    set playerColors[4] = "|c00fffc01"
    set playerColors[5] = "|c00ff8000"
    set playerColors[6] = "|c0020c000"
    set playerColors[7] = "|c00e55bb0"
    set playerColors[8] = "|c00959697"
    set playerColors[9] = "|c007ebff1"
    set playerColors[10] = "|c00106246"
    set playerColors[11] = "|c004e2a04"
    set playerColors[12] = "|c009b0000"
    set playerColors[13] = "|c000000c3"
    set playerColors[14] = "|c0000eaff"
    set playerColors[15] = "|c00be00fe"
    set playerColors[16] = "|c00ebcd87"
    set playerColors[17] = "|c00f8a48b"
    set playerColors[18] = "|c00bfff80"
    set playerColors[19] = "|c00dcb9eb"
    set playerColors[20] = "|c00282828"
    set playerColors[21] = "|c00ebf0ff"
    set playerColors[22] = "|c0000781e"
    set playerColors[23] = "|c00a46f33"
endfunction

endlibrary
