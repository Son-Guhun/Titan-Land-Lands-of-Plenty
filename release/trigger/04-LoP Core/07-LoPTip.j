library LoPTip requires TableStruct, GAL, LoPWarn

globals
    private constant key PERIODIC_TIPS
    public boolean enabled = true
endglobals

struct LoP_TipCategory extends array

    // these are supposed to be private
    //! runtextmacro TableStruct_NewStructField("tips","ArrayList")
    //! runtextmacro TableStruct_NewPrimitiveField("currentIndex","integer")
    
    // returns a list of tips (as integers)
    method getTips takes nothing returns ArrayList
        return .tips.copy()
    endmethod
    
    // no safety check for empty list
    method getNextTip takes nothing returns LoP_Tip
        local integer currentIndex = .currentIndex
    
        if currentIndex == 0 then
            call .tips.randomize()
        endif
        
        set .currentIndex = ModuloInteger(currentIndex + 1, tips.size)
        return .tips[currentIndex]
    endmethod

endstruct

struct LoP_Tip extends array

    //! runtextmacro TableStruct_NewReadonlyStructField("category","LoP_TipCategory")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("message","string")
    
    
    static method create takes LoP_TipCategory category, string message returns LoP_Tip
        local integer this = StringHash(message)
        set .category = category
        set .message = message
        call category.tips.append(this)
        return this
    endmethod
    
endstruct

/*
    To support more costumizable tips for each player, we need to avoid desyncs when using random numbers.
    
    One way would be to have each category have a separate list of tips for each player.

*/

private function onTimer takes nothing returns nothing
    local LoP_Tip tip = LoP_TipCategory(PERIODIC_TIPS).getNextTip()
    
    if enabled then
        call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.HINT, tip.message)
    endif
endfunction

private constant function DELAY_MINUTES takes nothing returns real
    return 10.
endfunction

private constant function DELAY_SECONDS takes nothing returns real
    return 0.
endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can use the |cffffff00-rect|r command to spawn a Rect Generator. This allows you to do stuff like save terrain, create terrain fog to make areas darker or brighter, or move a lot of units at once. Read the tooltips (you can use -seln rect to select your generator after you have spawned one)!")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can copy any unit using the |cffffff00-copy|r command. Well... almost any unit.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "When selecting an active rect generator, some commands (like |cffffff00-give|r, |cffffff00'color|r, |cffffff00-select no|r and others) will apply to all units inside of the generator.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can use the |cffffff00-seln|r command to select any deco builder that you currently have? For example, |cffffff00-seln wat|r will select your water builder. |cffffff00-seln wa|r will select your water and wall builders.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "The |cffffff00-select no|r command, which allows you to make your decorations unselectable, reduces the lag from having too many units in the map. Use it!")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can turn almost any unit into a hero, using the |cffffff00-makehero|r command. You can add custom abilities to these heroes using the |cffffff00-ability|r command (see F9). Some units, like builders and decorations, can't become heroes.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can set the default color of all your units with the |cffffff00-setcolor|r command. This will not alter your player color in the chat or F11 screen.")                 
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can use the |cffffff00-tag|r command instead of |cffffff00-anim|r. For example, |cffffff00-tag work|r or |cffffff00-tag upgrade first|r. Tags, unlike animations, are saved by the Save System. They also consistently apply to units, even when they take other actions.") 
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "Rect Generators can be used to save terrain. Use the |cffffff00-rect|r command to spawn a generator, expand its rectangle to encompass the region you want, then use the |cffffff00-tsav|r command while selecting the Generator to save. You can then use the |cffffff00-request|r command to retrieve the terrain. |cffff0000Warning:|r Saving two saves with the same name will overwrite them.") 
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "This map employs a multipatrol system. Whenever a unit is issued a Patrol order, it retains all its past patrol points and patrols all of them. Patrol points are saved by the Save System. Check F9 for commands.") 
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "This map contains many camera commands, so you can take screenshots of your builds from any angle! There is also a third person camera. Check F9 for more info.") 
        // call LoP_Tip.create(PERIODIC_TIPS, /*
        //                  */ "You can access the ingame Terrain Editor with the |cffffff00-editor terrain|r command. To return to play mode, use |cffffff00-editor none|r.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "You can add or remove many abilities from your heroes using the |cffffff00-ability|r  command (see F9). This includes units made into heroes using the |cffffff00-makehero|r command.")
        call LoP_Tip.create(PERIODIC_TIPS, /*
                         */ "If you are experiencing lag, try using the |cffffff00-count|r command to see how many units exist in the map and try to prune unecessary units.")
        
        call TimerStart(CreateTimer(), DELAY_MINUTES()*60. + DELAY_SECONDS(), true, function onTimer)
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

struct LoPHints extends array
    /*
    This struct is used to display common hints that are used in multiple commands. Each hint will
    only be displayed once per game.
    
    It also has functionality to display a random hint from an ArrayList of hints.
    */

    readonly static string array hints
    
    method operator msg takes nothing returns string
        return hints[this]
    endmethod
    
    private boolean seen // async
    
    static constant integer REMOVE_UNIT_HOTKEY = 1
    static constant integer COMMAND_CHATBOX = 2
    static constant integer COMMAND_DELETEME = 3
    static constant integer COMMAND_NAMEUNIT = 4
    static constant integer HOTKEY_RACE_SELECTOR = 5
    static constant integer HOTKEY_RECT_GENERATOR = 6
    static constant integer CHAT_LOGS = 7
    
    
    private static method onInit takes nothing returns nothing
        set hints[REMOVE_UNIT_HOTKEY] = "You can use the hotkey Shift+Backspace to remove units."
        set hints[COMMAND_CHATBOX] = "Use the -chatbox command to configure your chatbox preferences."
        set hints[COMMAND_DELETEME] = "You can delete all your units outside of the Titan Palace with -deleteme."
        set hints[COMMAND_NAMEUNIT] = "You can rename a unit using -nameunit."
        set hints[HOTKEY_RACE_SELECTOR] = "You can spawn a Race Selector using Alt+W."
        set hints[HOTKEY_RECT_GENERATOR] = "You can spawn a Rect Generator using Alt+R."
        set hints[CHAT_LOGS] = "You can view a more detailed chat log in the Tools menu (Ctrl+F4)."
        
        // Make array the same size for all players
        set hints[32] = "final hint"
    endmethod

    // This method sets the state of whether a hint has been seen or not in an async manner.
    // Returns false if player has already seen the hint. Returns true if they haven't, and for players that aren't <whichPlayer> (async).
    method displayToPlayer takes player whichPlayer returns boolean
        if User.Local == whichPlayer then
            if enabled and not .seen then
                set .seen = true
                
                call LoP_WarnPlayer(whichPlayer, LoPChannels.HINT, .msg)
                return true
            else
                return false
            endif
        endif
        return true
    endmethod
    
    // This is not safe to be called async (would need to change how displayToPlayer works in order to make it safe)
    static method displayFromList takes player whichPlayer, ArrayList list returns nothing
        local integer size = list.size
        local integer i = GetRandomInt(0, size-1)
        local integer first = i
        
        loop
            exitwhen thistype(list[i]).displayToPlayer(whichPlayer) // async
            
            set i = i + 1
            if i == size then
                set i = 0
            endif
            exitwhen i == first
        endloop
    endmethod
endstruct

endlibrary