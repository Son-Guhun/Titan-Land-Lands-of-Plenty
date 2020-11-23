scope CommandsChatbox

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local player trigP = GetTriggerPlayer()

    if args == "" or args == "help" then
        call LoP_WarnPlayer(trigP, LoPChannels.HINT, "Available arguments:
|cffffcc00(advanced/default)|r: choose which kind of chatbox to use when pressing enter.
|cffffcc00commands (show/hide)|r: show or hide messages containing commands.")

    elseif args == "advanced" then
        if User.Local == trigP then
            set LoP_useAdvancedChatBox = true
        endif
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Advanced Chatbox is now being used.")
        
    elseif args == "default" then
        if User.Local == trigP then
            set LoP_useAdvancedChatBox = false
        endif
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Default Chatbox is now being used. Use Ctrl+Shift+Enter to acces the Advanced Chatbox.")
        
    elseif args == "commands show" then
        if User.Local == trigP then
            set LoP_displayCommands = true
        endif
    
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Command display enabled for Advanced Chatbox.")
    elseif args == "commands hide" then
        if User.Local == trigP then
            set LoP_displayCommands = false
        endif
        
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Command display disabled for Advanced Chatbox.")
    endif

    
    // Do stuff
    
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Chatbox takes nothing returns nothing
    call LoP_Command.create("-chatbox", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope