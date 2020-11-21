scope ChatMessageHandler
/*
    This code is called whenever a player sends a chat message using the default WC3 chatbox.

    It will execute commands using LoPCommands_MessageHandler(). If the message was not a command, it
will be handled using SotDRPMessageHandler() for logging and display.
*/

private struct G extends array
    static key static_members_key
    //! runtextmacro TableStruct_NewStaticStructField("hints", "ArrayList")

endstruct

function Trig_Chat_Message_Handler_Actions takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local integer len = StringLength(msg)
    local integer id = GetPlayerId(GetTriggerPlayer())
    
    if SubString(msg, 0, 1) == "-" or SubString(msg, 0, 1) == "'" then
        if LoPCommands_MessageHandler() then
            return
        endif
    endif
    
    if Timeline.game.elapsed < 3600. and Timeline.game.elapsed > 30. then
        call LoPHints.displayFromList(GetTriggerPlayer(), G.hints)
    endif
    
    if len > 2 then
        if SubString(msg, 0, 2) == "((" then
            call SotDRPMessageHandler(id, SubString(msg, 2, len), true)
        elseif SubString(msg, len-2, len) == "))" then
            call SotDRPMessageHandler(id, SubString(msg, 0, len-2), true)
        else
            call SotDRPMessageHandler(id, msg, false)
        endif
    else
        call SotDRPMessageHandler(id, msg, false)
    endif
endfunction

//===========================================================================
function InitTrig_Chat_Message_Handler takes nothing returns nothing
    local User pId = 0

    set gg_trg_Chat_Message_Handler = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Chat_Message_Handler, function Trig_Chat_Message_Handler_Actions )
    
    set G.hints = ArrayList.create()
    call G.hints.append(LoPHints.CHAT_LOGS)
    call G.hints.append(LoPHints.COMMAND_CHATBOX)
    
    loop
        exitwhen pId == bj_MAX_PLAYERS
        if GetPlayerController(pId.handle) == MAP_CONTROL_USER then
            call TriggerRegisterPlayerChatEvent(gg_trg_Chat_Message_Handler, pId.handle, "", false)
        endif
        set pId = pId + 1
    endloop
endfunction

endscope
