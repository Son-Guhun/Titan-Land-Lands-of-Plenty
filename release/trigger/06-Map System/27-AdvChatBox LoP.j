/*
    This code handles the Advanced Chat Box. For more documentation, you can find the relevant libraries
in the AdvChatBox folder.

*/

globals
    boolean LoP_displayCommands = false  // async
    boolean LoP_useAdvancedChatBox = false // async
endglobals

struct AdvChatBoxLoP extends array

    // Maximum number of unique players that will be displayed in the typing frame, before it becomes "Many players are typing...".
    static constant integer MAX_TYPING_DISPLAY_COUNT = 4
    // Holds the IC/OOC boolean for each player.
    static boolean array isIC

    // This is the name displayed in the "is typing" frame. It is executed locally (desync hazard).
    static method getDisplayName takes player whichPlayer returns string
        local string name = GetPlayerName(whichPlayer)
        return UserColor(User[whichPlayer]).hex + SubString(name, 0, IMinBJ(15, StringLength(name))) + "|r"
    endmethod

    // This is called every 0.25 seconds, checking for special symbols/shortcuts in the message being typed.It is executed locally (desync hazard).
    static method parseChatSymbols takes string msg returns string
        local integer len = StringLength(msg)
        local string subStr = SubString(msg, len-2, len)
        local User pId = User.fromLocal()
        
        if StringLength(msg) > 1  then
            if subStr == "))" and isIC[pId] then
                call BlzFrameClick(AdvChatBox.oocButtonNoBuffer)
                set msg = SubString(msg, 0, len - 2)
                
            elseif subStr == "}}" and not isIC[pId] then
                call BlzFrameClick(AdvChatBox.oocButtonNoBuffer)
                set msg = SubString(msg, 0, len - 2)
                
            elseif subStr == "((" and isIC[pId] then
                call BlzFrameClick(AdvChatBox.sendButton)
                set msg = SubString(msg, 0, len - 2)
                
            elseif subStr == "{{" and not isIC[pId] then
                call BlzFrameClick(AdvChatBox.sendButton)
                set msg = SubString(msg, 0, len - 2)
            endif
        endif
        return msg
    endmethod

    // This is called when a player actually sends a message (presses enter).
    static method sendMessageHandler takes player sender, string msg, string extendedMsg returns nothing
        local string oldName
        local boolean OOC = not isIC[User[sender]]
        
        if SubString(msg, 0, 1) == "-" or SubString(msg, 0, 1) == "'" and LoPCommands_ExecuteCommand(msg) then
                if extendedMsg != "" then
                    call LoP_WarnPlayer(sender, LoPChannels.WARNING, "Commands are limited to 128 characters. Further characters are ignored.")
                endif
            
                if User.Local == sender then
                    if LoP_displayCommands then
                        call BlzDisplayChatMessage(sender, 0, msg)
                    endif
                    call BlzFrameSetFocus(AdvChatBox.editBox, false)
                    call BlzFrameSetVisible(AdvChatBox.editBox, false)
                endif
        else
            if extendedMsg != "" then
                set oldName = GetPlayerName(sender)
                if OOC then
                    call BlzDisplayChatMessage(sender, 0, "((" + msg)
                else
                    call BlzDisplayChatMessage(sender, 0, msg)
                endif
                
                call SetPlayerName(sender, " ")
                if OOC then
                    call BlzDisplayChatMessage(sender, 0, extendedMsg + "))")
                else
                    call BlzDisplayChatMessage(sender, 0, extendedMsg)
                endif
                
                call SetPlayerName(sender, oldName)
            else
                if OOC then
                    call BlzDisplayChatMessage(sender, 0, "((" + msg)
                else
                    call BlzDisplayChatMessage(sender, 0, msg)
                endif
            endif
            
            call SotDRPMessageHandler(User[sender], msg + extendedMsg, OOC)
        endif
        
        if User.Local == sender then
            call BlzFrameSetText(AdvChatBox.editBox, "")
        endif
    endmethod

    implement AdvChatBoxController
    
    
    static method onTimer takes nothing returns nothing
        if BlzFrameIsVisible(defaultChatBox) and LoP_useAdvancedChatBox then
            call BlzFrameSetVisible(defaultChatBox, false)
            call BlzFrameSetVisible(AdvChatBox.editBox, true)
            call BlzFrameSetFocus(AdvChatBox.editBox, true)
        endif
    endmethod
    
    static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 1/32., true, function thistype.onTimer)
    endmethod
endstruct